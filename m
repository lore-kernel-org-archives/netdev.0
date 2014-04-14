From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [RFC] sh_eth: use RNC mode for R8A7790
Date: Mon, 14 Apr 2014 18:35:21 +0200
Message-ID: <CAMuHMdX_7eX1F7PkO4WAkUdeNgPjkY_LozGZFeAROEN=K0Jp2w@mail.gmail.com>
References: <1396025185-7911-1-git-send-email-ben.dooks@codethink.co.uk>
	<5335DDC7.8040400@cogentembedded.com>
	<534BD8F9.5080105@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	magnus.damm@opensource.se,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:60435 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754175AbaDNQfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 12:35:23 -0400
In-Reply-To: <534BD8F9.5080105@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Mon, Apr 14, 2014 at 2:47 PM, Ben Dooks <ben.dooks@codethink.co.uk> wrote:
> On 28/03/14 20:38, Sergei Shtylyov wrote:
>> On 03/28/2014 07:46 PM, Ben Dooks wrote:
>>> The current behaviour of the sh_eth driver is not to use the RNC bit
>>> for the receive ring. This means that every packet recieved is not only
>>> generating an IRQ but it also stops the receive ring DMA as well until
>>> the driver re-enables it after unloading the packet.
>>
>>> This means that a number of the following errors are generated due to
>>> the receive packet FIFO overflowing due to nowhere to put packets:
>>
>>>     net eth0: Receive FIFO Overflow
>>
>>> Setting the RMCR_RNC configuration has so far been tested with an NFS
>>> root filesystem and the driver has not failed yet. It is not yet known
>>> why this is not set for R8A779x operation
>>
>>     The reason is simple: it's not set on almost all 100 Mbs devices
>> except SH7757 (and most recently added R7S72100), so this was a matter
>> of copy-paste. I've had setting this bit on at least R-Car devices on my
>> aganda for some time but couldn't get to it yet.
>>
>>> (Feedback on this issue or other testing is welcome)
>>
>>     OK, I'll try it with netperf UDP test known to generate handful of
>> the aforementioned errors, when I have time.
>
> Has anyone had time to look at this?

I gave it a try on Koelsch (it does apply to r8a7791, too, right?), and didn't
see any good or ill effects. Just using NFS root and generating some I/O,
so nothing fancy.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
