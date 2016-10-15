From: Robert Jarzmik <robert.jarzmik-GANU6spQydw@public.gmane.org>
Subject: [PATCH v2 0/3] support smc91x on mainstone and devicetree
Date: Sat, 15 Oct 2016 21:27:47 +0200
Message-ID: <1476559670-25056-1-git-send-email-robert.jarzmik@free.fr>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Robert Jarzmik <robert.jarzmik-GANU6spQydw@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Nicolas Pitre <nico-vtqb6HGKxmzR7s880joybQ@public.gmane.org>,
        Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This serie aims at bringing support to mainstone board on a device-tree based
build, as what is already in place for legacy mainstone.

The bulk of the mainstone "specific" behavior is that a u16 write doesn't work
on a address of the form 4*n + 2, while it works on 4*n.

The legacy workaround was in SMC_outw(), with calls to
machine_is_mainstone(). These calls don't work with a pxa27x-dt machine type,
which is used when a generic device-tree pxa27x machine is used to boot the
mainstone board.

Therefore, this serie enables the smc91c111 adapter of the mainstone board to
work on a device-tree build, exaclty as it's been working for years with the
legacy arch/arm/mach-pxa/mainstone.c definition.

Cheers.

--
Robert

Robert Jarzmik (3):
  net: smc91x: isolate u16 writes alignment workaround
  net: smc91x: take into account half-word workaround
  net: smsc91x: add u16 workaround for pxa platforms

 .../devicetree/bindings/net/smsc-lan91c111.txt     |  2 +
 drivers/net/ethernet/smsc/smc91x.c                 |  8 ++-
 drivers/net/ethernet/smsc/smc91x.h                 | 78 ++++++++++++----------
 3 files changed, 52 insertions(+), 36 deletions(-)

-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
