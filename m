From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v2 1/2 -net] ravb: Add missing free_irq() call to ravb_close()
Date: Sat, 7 May 2016 21:42:35 +0200
Message-ID: <CAMuHMdXse+4E0=71ErEv6hiWQ7-G2eM8aQAh9dF8wCyCPLQOvA@mail.gmail.com>
References: <1462619832-5177-1-git-send-email-geert+renesas@glider.be>
	<1462619832-5177-2-git-send-email-geert+renesas@glider.be>
	<572E3673.5020304@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Geert Uytterhoeven <geert+renesas@glider.be>,
	"David S. Miller" <davem@davemloft.net>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Simon Horman <horms+renesas@verge.net.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f193.google.com ([209.85.213.193]:32910 "EHLO
	mail-ig0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbcEGTmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 15:42:36 -0400
In-Reply-To: <572E3673.5020304@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 7, 2016 at 8:39 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> On 05/07/2016 02:17 PM, Geert Uytterhoeven wrote:
>
>> When reopening the network device on ra7795/salvator-x, e.g. after a
>> DHCP timeout:
>>
>>      IP-Config: Reopening network devices...
>>      genirq: Flags mismatch irq 139. 00000000 (eth0:ch24:emac) vs.
>> 00000000 (eth0:ch24:emac)
>>      ravb e6800000.ethernet eth0: cannot request IRQ eth0:ch24:emac
>
>    Er, this can't be a message from the kernel built from net.git. That
> driver used 'ndev->name'
> to request both IRQs...

Oops, I copied the error message from the second patch.
I don't think it matters that much, though...

>>      IP-Config: Failed to open eth0
>>      IP-Config: No network devices available
>>
>> The "mismatch" is due to requesting an IRQ that is already in use,
>> while IRQF_PROBE_SHARED wasn't set.
>>
>> However, the real cause is that ravb_close() doesn't release the R-Car
>> Gen3-specific secondary IRQ.
>>
>> Add the missing free_irq() call to fix this.
>>
>> Fixes: 22d4df8ff3a3cc72 ("ravb: Add support for r8a7795 SoC")
>> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
>
>
> Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Thanks!

Gr{oetje,eeting}s,

                        Geert
