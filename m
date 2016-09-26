From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: stmmac/RTL8211F/Meson GXBB: TX throughput problems
Date: Mon, 26 Sep 2016 08:17:50 +0200
Message-ID: <d59f6e2c-15ff-779d-da2f-8eb5f5a535a6@st.com>
References: <CAFBinCALSL_-izJ2tEsAjevAw90kGNTrQ3na3D1YV8f1dS1=Xg@mail.gmail.com>
 <ff6f3501-fbd5-3e79-dcc1-549406a5144b@st.com>
 <CAFBinCD42A_SqQz8GM-H+A32dMELknAytHuJ5T2YgZ3BrMKA3A@mail.gmail.com>
 <20160917232312.1e30d425@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Alexandre Torgue <alexandre.torgue@st.com>,
        Johnson Leung <r58129@freescale.com>, <netdev@vger.kernel.org>,
        <linux-amlogic@lists.infradead.org>
To: =?UTF-8?Q?Andr=c3=a9_Roth?= <neolynx@gmail.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:51735 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932244AbcIZGS0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 02:18:26 -0400
In-Reply-To: <20160917232312.1e30d425@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello André

On 9/17/2016 11:23 PM, André Roth wrote:
>
> Hi all,
>
> I have an odroid c2 board which shows this issue. No data is
> transmitted or received after a moment of intense tx traffic. Copying a
> 1GB file per scp from the board triggers it repeatedly.
>
> The board has a stmmac - user ID: 0x11, Synopsys ID: 0x37.
>
> When switching the network to 100Mb/s the copying does
> not seam to trigger the issue.
>
> I've attached the ethtool statistics before and after the problem.

at first glance, it enters in EEE mode often in the ethtool.after.
On some platforms we met problems and it was necessary to disable the
feature. Maybe, you can start looking at if this is true on yours.
We will see to provide a clean subset of patches to switch-on/off it.

Peppe

>
> Thanks for your help,
>
>  André
>
>
>
>> Hi Alexandre,
>>
>> On Mon, Sep 12, 2016 at 6:37 PM, Alexandre Torgue
>> <alexandre.torgue@st.com> wrote:
>>> Which Synopsys IP version do you use ?
>> found this in a dmesg log:
>> [    1.504784] stmmac - user ID: 0x11, Synopsys ID: 0x37
>> [    1.509785]  Ring mode enabled
>> [    1.512796]  DMA HW capability register supported
>> [    1.517286]  Normal descriptors
>> [    1.520565]  RX Checksum Offload Engine supported
>> [    1.525219]  COE Type 2
>> [    1.527638]  TX Checksum insertion supported
>> [    1.531862]  Wake-Up On Lan supported
>> [    1.535483]  Enable RX Mitigation via HW Watchdog Timer
>> [    1.543851] libphy: stmmac: probed
>> [    1.544025] eth0: PHY ID 001cc916 at 0 IRQ POLL (stmmac-0:00)
>> active [    1.550321] eth0: PHY ID 001cc916 at 7 IRQ POLL
>> (stmmac-0:07)
>>
>>>> Gbit ethernet on my device is provided by a Realtek RTL8211F RGMII
>>>> PHY. Similar issues were reported in #linux-amlogic by a user with
>>>> an Odroid C2 board (= similar hardware).
>>>>
>>>> The symptoms are:
>>>> Receiving data is plenty fast (I can max out my internet connection
>>>> easily, and with iperf3 I get ~900Mbit/s).
>>>> Transmitting data from the device is unfortunately very slow,
>>>> traffic sometimes even stalls completely.
>>>>
>>>> I have attached the iperf results and the output of
>>>> /sys/kernel/debug/stmmaceth/eth0/descriptors_status.
>>>> Below you can find the ifconfig, netstat and stmmac dma_cap info
>>>> (*after* I ran all tests).
>>>>
>>>> The "involved parties" are:
>>>> - Meson GXBB specific network configuration registers (I have have
>>>> double-checked them with the reference drivers: everything seems
>>>> fine here)
>>>> - stmmac: it seems that nobody else has reported these kind of
>>>> issues so far, however I'd still like to hear where I should
>>>> enable some debugging bits to rule out any stmmac bug
>>>
>>>
>>> On my side, I just tested on the same "kind" of system:
>>> -SYNOPSYS GMAC 3.7
>>> -RTL8211EG as PHY
>>>
>>> With I perf, I reach:
>>>         -RX: 932 Mbps
>>>         -TX: 820Mbps
>>>
>>> Can you check ethtool -S eth0 (most precisely "MMC"counter and
>>> errors) ? Which kernel version do you use ?
>> I am using a 4.8.0-rc4 kernel, based on Kevin's "integration" branch:
>> [0] Unfortunately I don't have access to my device in the next few
>> days, but I'll keep you updated once I have the ethtool output.
>>
>>
>> Thanks for your time
>> Regards,
>> Martin
>>
>>
>> [0]
>> https://git.kernel.org/cgit/linux/kernel/git/khilman/linux-amlogic.git/log/?h=v4.8/integ
>>
>> _______________________________________________
>> linux-amlogic mailing list
>> linux-amlogic@lists.infradead.org
>> http://lists.infradead.org/mailman/listinfo/linux-amlogic
>>
>
