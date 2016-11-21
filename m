From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: Synopsys Ethernet QoS Driver
Date: Mon, 21 Nov 2016 13:52:42 +0100
Message-ID: <87c8a24b-0812-7850-cb3f-7be691bab432@st.com>
References: <CADvZ6ErjyVR5ShWTk0QesWLYR1m3p8yAMkK8v9gm2kN5xTv8zw@mail.gmail.com>
 <1dbb6047-2bbb-4d56-2a62-ab65a0254844@synopsys.com>
 <20161119135654.GA14079@lnxartpec.se.axis.com>
 <CAJ3bTp7PpUJcz=1JohX=A54UP6vVAafWnB0PGUBSxb5JJiO8Lg@mail.gmail.com>
 <1248f4ce-4859-10e6-fef9-342ea543f8d4@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: andreas.irestal@axis.com, Alexandre TORGUE <alexandre.torgue@st.com>,
 saeedm@mellanox.com, netdev <netdev@vger.kernel.org>,
 linux-kernel@vger.kernel.org, CARLOS.PALMINHA@synopsys.com,
 idosch@mellanox.com, mued dib <kreptor@gmail.com>, jiri@mellanox.com,
 Jeff Kirsher <jeffrey.t.kirsher@intel.com>, David Miller <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 lars.persson@axis.com
To: Joao Pinto <Joao.Pinto@synopsys.com>, Rayagond Kokatanur
 <rayagond@vayavyalabs.com>, Rabin Vincent <rabin@rab.in>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1248f4ce-4859-10e6-fef9-342ea543f8d4@synopsys.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hello Joao

On 11/21/2016 1:32 PM, Joao Pinto wrote:
> Hello,
>
> On 21-11-2016 05:29, Rayagond Kokatanur wrote:
>> On Sat, Nov 19, 2016 at 7:26 PM, Rabin Vincent <rabin@rab.in> wrote:
>>> On Fri, Nov 18, 2016 at 02:20:27PM +0000, Joao Pinto wrote:
>>>> For now we are interesting in improving the synopsys QoS driver under
>>>> /nect/ethernet/synopsys. For now the driver structure consists of a single file
>>>> called dwc_eth_qos.c, containing synopsys ethernet qos common ops and platform
>>>> related stuff.
>>>>
>>>> Our strategy would be:
>>>>
>>>> a) Implement a platform glue driver (dwc_eth_qos_pltfm.c)
>>>> b) Implement a pci glue driver (dwc_eth_qos_pci.c)
>>>> c) Implement a "core driver" (dwc_eth_qos.c) that would only have Ethernet QoS
>>>> related stuff to be reused by the platform / pci drivers
>>>> d) Add a set of features to the "core driver" that we have available internally
>>>
>>> Note that there are actually two drivers in mainline for this hardware:
>>>
>>>  drivers/net/ethernet/synopsis/
>>>  drivers/net/ethernet/stmicro/stmmac/
>>
>> Yes the later driver (drivers/net/ethernet/stmicro/stmmac/) supports
>> both 3.x and 4.x. It has glue layer for pci, platform, core etc,
>> please refer this driver once before you start.
>>
>> You can start adding missing feature of 4.x in stmmac driver.
>
> Thanks you all for all the info.
> Well, I think we are in a good position to organize the ethernet drivers
> concerning Synopsys IPs.
>
> First of all, in my opinion, it does not make sense to have a ethernet/synopsis
> (typo :)) when ethernet/stmicro is also for a synopsys IP. If we have another
> vendor using the same IP it should be able to reuse the commonn operations. But
> I would put that discussion for later :)
>
> For now I suggest that for we create ethernet/qos and create there a folder
> called dwc (designware controller) where all the synopsys qos IP specific code
> in order to be reused for example by ethernet/stmicro/stmmac/. We just have to
> figure out a clean interface for "client drivers" like stmmac to interact with
> the new qos driver.
>
> What do you think about this approach?

The stmmac drivers run since many years on several platforms
(sh4, stm32, arm, x86, mips ...) and it supports an huge of amount of
configurations starting from 3.1x to 3.7x databooks.

It also supports QoS hardware; for example, 4.00a, 4.10a and 4.20a
are fully working.

Also the stmmac has platform, device-tree and pcie supports and
a lot of maintained glue-logic files.

It is fully documented inside the kernel tree.

I am happy to have new enhancements from other developers.
So, on my side, if you want to spend your time on improving it on your
platforms please feel free to do it!

Concerning the stmicro/stmmac naming, these come from a really old
story and have no issue to adopt new folder/file names.

I am also open to merge fixes and changes from ethernet/synopsis.
I want to point you on some benchmarks made by Alex some months ago
(IIRC) that showed an stmmac winner (due to the several optimizations
analyzed and reviewed in this mailing list).

Peppe

>
>
>>
>>>
>>> (See http://lists.openwall.net/netdev/2016/02/29/127)
>>>
>>> The former only supports 4.x of the hardware.
>>>
>>> The later supports 4.x and 3.x and already has a platform glue driver
>>> with support for several platforms, a PCI glue driver, and a core driver
>>> with several features not present in the former (for example: TX/RX
>>> interrupt coalescing, EEE, PTP).
>>>
>>> Have you evaluated both drivers?  Why have you decided to work on the
>>> former rather than the latter?
>>
>>
>
> Thanks.
>
>
>
>
