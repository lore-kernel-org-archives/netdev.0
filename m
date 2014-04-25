From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC] sh_eth: use RNC mode for R8A7790
Date: Sat, 26 Apr 2014 03:54:08 +0400
Message-ID: <535AF5A0.6010206@cogentembedded.com>
References: <1396025185-7911-1-git-send-email-ben.dooks@codethink.co.uk>	<5335DDC7.8040400@cogentembedded.com>	<534BD8F9.5080105@codethink.co.uk>	<CAMuHMdX_7eX1F7PkO4WAkUdeNgPjkY_LozGZFeAROEN=K0Jp2w@mail.gmail.com> <CAMuHMdUwDxb5K+Q335isLE-+HLwbwGSksp0KYmGoaXGYQmSiug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	magnus.damm@opensource.se,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: Geert Uytterhoeven <geert@linux-m68k.org>,
	Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdUwDxb5K+Q335isLE-+HLwbwGSksp0KYmGoaXGYQmSiug@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 04/14/2014 08:48 PM, Geert Uytterhoeven wrote:

>>>>> The current behaviour of the sh_eth driver is not to use the RNC bit
>>>>> for the receive ring. This means that every packet recieved is not only
>>>>> generating an IRQ but it also stops the receive ring DMA as well until
>>>>> the driver re-enables it after unloading the packet.

>>>>> This means that a number of the following errors are generated due to
>>>>> the receive packet FIFO overflowing due to nowhere to put packets:

>>>>>      net eth0: Receive FIFO Overflow

>>>>> Setting the RMCR_RNC configuration has so far been tested with an NFS
>>>>> root filesystem and the driver has not failed yet. It is not yet known
>>>>> why this is not set for R8A779x operation

>>>>      The reason is simple: it's not set on almost all 100 Mbs devices
>>>> except SH7757 (and most recently added R7S72100), so this was a matter
>>>> of copy-paste. I've had setting this bit on at least R-Car devices on my
>>>> aganda for some time but couldn't get to it yet.

>>>>> (Feedback on this issue or other testing is welcome)

>>>>      OK, I'll try it with netperf UDP test known to generate handful of
>>>> the aforementioned errors, when I have time.

>>> Has anyone had time to look at this?

>> I gave it a try on Koelsch (it does apply to r8a7791, too, right?), and didn't
>> see any good or ill effects. Just using NFS root and generating some I/O,
>> so nothing fancy.

> FWIW, I still have "renesas,no-ether-link" in the ethernet node in DT.

    You shouldn't need it anymore if you're using recent devel branch of the 
renesas.git repo: it already has the necessary PHY driver and device tree 
changes to avoid the issue which specifying that prop fixed.

> Gr{oetje,eeting}s,

WBR, Sergei

