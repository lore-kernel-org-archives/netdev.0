From: Kumar Gala <galak@gate.crashing.org>
Subject: proper way to deal with a sparse warning (fwd)
Date: Mon, 23 Jan 2006 10:21:43 -0600 (CST)
Message-ID: <Pine.LNX.4.44.0601231021010.11937-100000@gate.crashing.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751478AbWAWQ2z@vger.kernel.org>
To: netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I wasn't getting much of a response on lkml to this, so maybe netdev will 
be more helpful :)

thanks

- kumar

---------- Forwarded message ----------
Date: Thu, 19 Jan 2006 00:19:47 -0600
From: Kumar Gala <galak@kernel.crashing.org>
To: LKML List <linux-kernel@vger.kernel.org>
Subject: proper way to deal with a sparse warning

I'm getting the following sparse warning:

drivers/net/gianfar_mii.c:165:16: warning: incorrect type in  
assignment (different address spaces)
drivers/net/gianfar_mii.c:165:16:    expected void *priv
drivers/net/gianfar_mii.c:165:16:    got struct gfar_mii [noderef] * 
[assigned] regs<asn:2>

This is line 165 of gianfar_mii.c:

         new_bus->priv = regs;

new_bus->priv is of type void *.  regs is of type struct gfar_mii  
__iomem *.

Is it acceptable to do the following:

	new_bus->priv = (void __force *)regs;

- kumar

