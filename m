From: Li Yang <leoli@freescale.com>
Subject: Re: [PATCH 1/6] rapidio: add common mapping APIs for RapidIO memory
	access
Date: Mon, 15 Jun 2009 18:38:56 +0800
Message-ID: <2a27d3730906150338u224126e1yf6fb0b77675a6633@mail.gmail.com>
References: <1242117363-14949-1-git-send-email-leoli@freescale.com>
	 <90AED712-28A1-4800-978C-125A887D0DA7@kernel.crashing.org>
	 <3A45394FD742FA419B760BB8D398F9ED483CCD@zch01exm26.fsl.freescale.net>
	 <5D8775BD-9973-4DE8-B442-91FB15F86ACC@kernel.crashing.org>
	 <2a27d3730906120627l112030b3wa11ea5aa3fcb1087@mail.gmail.com>
	 <718B5524-9FB1-4835-BAEA-C5B990F78DAC@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	mporter@kernel.crashing.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Zhang Wei <zw@zh-kernel.org>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.244]:41110 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753172AbZFOKiy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 06:38:54 -0400
In-Reply-To: <718B5524-9FB1-4835-BAEA-C5B990F78DAC@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 12, 2009 at 9:58 PM, Kumar Gala<galak@kernel.crashing.org> =
wrote:
>
> On Jun 12, 2009, at 8:27 AM, Li Yang wrote:
>
>> On Thu, Jun 11, 2009 at 9:32 PM, Kumar Gala<galak@kernel.crashing.or=
g>
>> wrote:
>>>
>>> On Jun 11, 2009, at 4:47 AM, Li Yang-R58472 wrote:
>>>
>>>>> On May 12, 2009, at 3:35 AM, Li Yang wrote:
>>>>>
>>>>>> Add the mapping functions used to support direct IO memory acces=
s of
>>>>>> rapidIO.
>>>>>>
>>>>>> Signed-off-by: Zhang Wei <zw@zh-kernel.org>
>>>>>> Signed-off-by: Li Yang <leoli@freescale.com>
>>>>>
>>>>> Use inbnd/outbnd instead of inb/outb which make one think of
>>>>> byte level io accessors.
>>>>>
>>>>> As I look at this I don't think this is the correct API. =C2=A0I
>>>>> think we should be using the DMA mapping API to hide these
>>>>> details. =C2=A0The concept of mapping like this seems to be more =
a
>>>>> function of FSL's Address translation/mapping unit (ATMU) than
>>>>> anything specific to the RIO bus standard.
>>>>
>>>> This is a separate RIO block level ATMU. =C2=A0Although it looks l=
ike the
>>>> system level ATMU, system ATMU doesn't have the knowledge of rapid=
IO
>>>> target device ID. =C2=A0The mapping need to be dynamic, as it's ea=
sy to have
>>>> more RIO devices than the outbound windows.
>>>
>>> I understand that. =C2=A0What I'm saying is the RIO block level ATM=
U is a
>>> Freescale specific detail and not part of any standard RIO bus
>>> programming
>>> model. =C2=A0We have mapping APIs that we can connect to for this v=
ia the DMA
>>> API
>>> layer.
>>
>> Ok, I see your point now. Do you mean dma_map_*() for DMA API layer?
>> But in my understanding the current dma_map_*() APIs are preparing
>> local memory for device to access which is similar to the inbound
>> case. =C2=A0Is it suitable to also use them for mapping device's spa=
ce for
>> CPU access? =C2=A0Can you give an example of using this API for Addr=
ess
>> Translation and Mapping purpose?
>
> Yes, I meant the dma_map_*() API. =C2=A0Any system with a true IOMMU =
uses the
> dma_map_ layer as the way to do address translation.

IOMMU case is not very similar to the RapidIO scenario.  RapidIO
mapping is more like PCI address space mapping.

To be specific, the DMA API return dma_addr_t not the rapidIO address
type.  And they can only handle inbound mapping not both ways.  I
don't think the DMA API is competent enough to be used here for RIO
mapping.  Unless we have a more universal mapping API, it can be
justified to create its own API.

- Leo
