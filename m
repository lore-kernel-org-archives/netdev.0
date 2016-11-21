From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: Synopsys Ethernet QoS Driver
Date: Mon, 21 Nov 2016 12:32:55 +0000
Message-ID: <1248f4ce-4859-10e6-fef9-342ea543f8d4@synopsys.com>
References: <CADvZ6ErjyVR5ShWTk0QesWLYR1m3p8yAMkK8v9gm2kN5xTv8zw@mail.gmail.com>
 <1dbb6047-2bbb-4d56-2a62-ab65a0254844@synopsys.com>
 <20161119135654.GA14079@lnxartpec.se.axis.com>
 <CAJ3bTp7PpUJcz=1JohX=A54UP6vVAafWnB0PGUBSxb5JJiO8Lg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Joao Pinto <Joao.Pinto@synopsys.com>, mued dib <kreptor@gmail.com>,
        David Miller <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        <jiri@mellanox.com>, <saeedm@mellanox.com>, <idosch@mellanox.com>,
        netdev <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <CARLOS.PALMINHA@synopsys.com>, <andreas.irestal@axis.com>,
        <alexandre.torgue@st.com>, <lars.persson@axis.com>
To: Rayagond Kokatanur <rayagond@vayavyalabs.com>,
        Rabin Vincent <rabin@rab.in>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJ3bTp7PpUJcz=1JohX=A54UP6vVAafWnB0PGUBSxb5JJiO8Lg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 21-11-2016 05:29, Rayagond Kokatanur wrote:
> On Sat, Nov 19, 2016 at 7:26 PM, Rabin Vincent <rabin@rab.in> wrote:
>> On Fri, Nov 18, 2016 at 02:20:27PM +0000, Joao Pinto wrote:
>>> For now we are interesting in improving the synopsys QoS driver under
>>> /nect/ethernet/synopsys. For now the driver structure consists of a single file
>>> called dwc_eth_qos.c, containing synopsys ethernet qos common ops and platform
>>> related stuff.
>>>
>>> Our strategy would be:
>>>
>>> a) Implement a platform glue driver (dwc_eth_qos_pltfm.c)
>>> b) Implement a pci glue driver (dwc_eth_qos_pci.c)
>>> c) Implement a "core driver" (dwc_eth_qos.c) that would only have Ethernet QoS
>>> related stuff to be reused by the platform / pci drivers
>>> d) Add a set of features to the "core driver" that we have available internally
>>
>> Note that there are actually two drivers in mainline for this hardware:
>>
>>  drivers/net/ethernet/synopsis/
>>  drivers/net/ethernet/stmicro/stmmac/
> 
> Yes the later driver (drivers/net/ethernet/stmicro/stmmac/) supports
> both 3.x and 4.x. It has glue layer for pci, platform, core etc,
> please refer this driver once before you start.
> 
> You can start adding missing feature of 4.x in stmmac driver.

Thanks you all for all the info.
Well, I think we are in a good position to organize the ethernet drivers
concerning Synopsys IPs.

First of all, in my opinion, it does not make sense to have a ethernet/synopsis
(typo :)) when ethernet/stmicro is also for a synopsys IP. If we have another
vendor using the same IP it should be able to reuse the commonn operations. But
I would put that discussion for later :)

For now I suggest that for we create ethernet/qos and create there a folder
called dwc (designware controller) where all the synopsys qos IP specific code
in order to be reused for example by ethernet/stmicro/stmmac/. We just have to
figure out a clean interface for "client drivers" like stmmac to interact with
the new qos driver.

What do you think about this approach?


> 
>>
>> (See http://lists.openwall.net/netdev/2016/02/29/127)
>>
>> The former only supports 4.x of the hardware.
>>
>> The later supports 4.x and 3.x and already has a platform glue driver
>> with support for several platforms, a PCI glue driver, and a core driver
>> with several features not present in the former (for example: TX/RX
>> interrupt coalescing, EEE, PTP).
>>
>> Have you evaluated both drivers?  Why have you decided to work on the
>> former rather than the latter?
> 
> 

Thanks.
