From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 1/2 -net] ravb: Add missing free_irq() call to
 ravb_close()
Date: Sat, 7 May 2016 21:39:47 +0300
Message-ID: <572E3673.5020304@cogentembedded.com>
References: <1462619832-5177-1-git-send-email-geert+renesas@glider.be>
 <1462619832-5177-2-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Simon Horman <horms+renesas@verge.net.au>,
	netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:34979 "EHLO
	mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901AbcEGSjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 14:39:52 -0400
Received: by mail-lf0-f54.google.com with SMTP id j8so162601697lfd.2
        for <netdev@vger.kernel.org>; Sat, 07 May 2016 11:39:51 -0700 (PDT)
In-Reply-To: <1462619832-5177-2-git-send-email-geert+renesas@glider.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/07/2016 02:17 PM, Geert Uytterhoeven wrote:

> When reopening the network device on ra7795/salvator-x, e.g. after a
> DHCP timeout:
>
>      IP-Config: Reopening network devices...
>      genirq: Flags mismatch irq 139. 00000000 (eth0:ch24:emac) vs. 00000000 (eth0:ch24:emac)
>      ravb e6800000.ethernet eth0: cannot request IRQ eth0:ch24:emac

    Er, this can't be a message from the kernel built from net.git. That 
driver used 'ndev->name'
to request both IRQs...

>      IP-Config: Failed to open eth0
>      IP-Config: No network devices available
>
> The "mismatch" is due to requesting an IRQ that is already in use,
> while IRQF_PROBE_SHARED wasn't set.
>
> However, the real cause is that ravb_close() doesn't release the R-Car
> Gen3-specific secondary IRQ.
>
> Add the missing free_irq() call to fix this.
>
> Fixes: 22d4df8ff3a3cc72 ("ravb: Add support for r8a7795 SoC")
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
