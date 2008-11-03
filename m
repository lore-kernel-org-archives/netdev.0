From: "Mike Frysinger" <vapier@gentoo.org>
Subject: Re: smc91x: commit 51ac3beffd4afaea4350526cf01fe74aaff25eff breaks compilation
Date: Mon, 3 Nov 2008 02:30:01 -0500
Message-ID: <1aad82fa0811022330u3864f12che3f903a43402e043@mail.gmail.com>
References: <20081103071720.GB18153@roarinelk.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Manuel Lauss" <mano@roarinelk.homelinux.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:5377 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752579AbYKCHaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 02:30:02 -0500
Received: by wf-out-1314.google.com with SMTP id 27so2385355wfd.4
        for <netdev@vger.kernel.org>; Sun, 02 Nov 2008 23:30:01 -0800 (PST)
In-Reply-To: <20081103071720.GB18153@roarinelk.homelinux.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 3, 2008 at 2:17 AM, Manuel Lauss wrote:
> (Resend with correct netdev addr)
>
> Hi Mike,
>
> your commit 51ac3beffd4afaea4350526cf01fe74aaff25eff  causes this
> compile failure on my SH and MIPS testboards (2.6.28-rc3):
>
>  CC      drivers/net/smc91x.o
> /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c: In function 'smc_request_attrib':
> /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2067: error: 'lp' undeclared (first use in this function)
> /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2067: error: (Each undeclared identifier is reported only once
> /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2067: error: for each function it appears in.)
> /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c: In function 'smc_release_attrib':
> /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2079: error: 'lp' undeclared (first use in this function)
> make[2]: *** [drivers/net/smc91x.o] Error 1
> make[1]: *** [drivers/net/smc91x.o] Error 2
>
> Reverting this commit fixes it.

are you using modifiied sources or something ? there's clearly no lp
reference in mainline:
...
static int smc_request_attrib(struct platform_device *pdev,
                  struct net_device *ndev)
{
    struct resource * res = platform_get_resource_byname(pdev,
IORESOURCE_MEM, "smc91x-attrib");

    if (!res)
        return 0;

    if (!request_mem_region(res->start, ATTRIB_SIZE, CARDNAME))
        return -EBUSY;

    return 0;
}

static void smc_release_attrib(struct platform_device *pdev,
                   struct net_device *ndev)
{
    struct resource * res = platform_get_resource_byname(pdev,
IORESOURCE_MEM, "smc91x-attrib");

    if (res)
        release_mem_region(res->start, ATTRIB_SIZE);
}
...
-mike
