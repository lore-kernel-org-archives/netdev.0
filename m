From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 1/6] rapidio: add common mapping APIs for RapidIO memory
	access
Date: Fri, 12 Jun 2009 08:58:49 -0500
Message-ID: <718B5524-9FB1-4835-BAEA-C5B990F78DAC@kernel.crashing.org>
References: <1242117363-14949-1-git-send-email-leoli@freescale.com>
	<90AED712-28A1-4800-978C-125A887D0DA7@kernel.crashing.org>
	<3A45394FD742FA419B760BB8D398F9ED483CCD@zch01exm26.fsl.freescale.net>
	<5D8775BD-9973-4DE8-B442-91FB15F86ACC@kernel.crashing.org>
	<2a27d3730906120627l112030b3wa11ea5aa3fcb1087@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Content-Transfer-Encoding: 7bit
Cc: Zhang Wei <zw@zh-kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	linuxppc-dev@ozlabs.org, akpm@linux-foundation.org
To: Li Yang <leoli@freescale.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <2a27d3730906120627l112030b3wa11ea5aa3fcb1087@mail.gmail.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org


On Jun 12, 2009, at 8:27 AM, Li Yang wrote:

> On Thu, Jun 11, 2009 at 9:32 PM, Kumar  
> Gala<galak@kernel.crashing.org> wrote:
>>
>> On Jun 11, 2009, at 4:47 AM, Li Yang-R58472 wrote:
>>
>>>> On May 12, 2009, at 3:35 AM, Li Yang wrote:
>>>>
>>>>> Add the mapping functions used to support direct IO memory  
>>>>> access of
>>>>> rapidIO.
>>>>>
>>>>> Signed-off-by: Zhang Wei <zw@zh-kernel.org>
>>>>> Signed-off-by: Li Yang <leoli@freescale.com>
>>>>
>>>> Use inbnd/outbnd instead of inb/outb which make one think of
>>>> byte level io accessors.
>>>>
>>>> As I look at this I don't think this is the correct API.  I
>>>> think we should be using the DMA mapping API to hide these
>>>> details.  The concept of mapping like this seems to be more a
>>>> function of FSL's Address translation/mapping unit (ATMU) than
>>>> anything specific to the RIO bus standard.
>>>
>>> This is a separate RIO block level ATMU.  Although it looks like the
>>> system level ATMU, system ATMU doesn't have the knowledge of rapidIO
>>> target device ID.  The mapping need to be dynamic, as it's easy to  
>>> have
>>> more RIO devices than the outbound windows.
>>
>> I understand that.  What I'm saying is the RIO block level ATMU is a
>> Freescale specific detail and not part of any standard RIO bus  
>> programming
>> model.  We have mapping APIs that we can connect to for this via  
>> the DMA API
>> layer.
>
> Ok, I see your point now. Do you mean dma_map_*() for DMA API layer?
> But in my understanding the current dma_map_*() APIs are preparing
> local memory for device to access which is similar to the inbound
> case.  Is it suitable to also use them for mapping device's space for
> CPU access?  Can you give an example of using this API for Address
> Translation and Mapping purpose?

Yes, I meant the dma_map_*() API.  Any system with a true IOMMU uses  
the dma_map_ layer as the way to do address translation.

- k
