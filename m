From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: BUG null dereference in driver ./drivers/net/3c507.c
Date: Tue, 15 Dec 2009 15:14:34 +0100
Message-ID: <200912151514.34693.bzolnier@gmail.com>
References: <200912151755.08345.strakh@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Donald Becker <becker@scyld.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexander Strakh <strakh@ispras.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932245AbZLOOQW@vger.kernel.org>
In-Reply-To: <200912151755.08345.strakh@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

On Tuesday 15 December 2009 06:55:08 pm Alexander Strakh wrote:
> 	KERNEL_VERSION: 2.6.32
> 	SUBJECT: null dereference aftre check
> 	DESCRIBE:
> 	In driver drivers/net/3c507.c in function Iirqreturn_t el16_interrupt:
> 
> 1. If in line 555 dev = NULL then we goto line 556
> 2. In line 556 we have null dereference because pr_err called with dev->name 
> in third parameter.
> 
>  555        if (dev == NULL) {
>  556                pr_err("%s: net_interrupt(): irq %d for unknown device.
> \n",
>  557                        dev->name, irq);
>  558                return IRQ_NONE;
>  559        }

There is no NULL dereference bug there possible since 'dev' will never be
actually NULL in el16_interrupt() (because of the way IRQ kernel subsystem
and 3c507 network driver are designed/work).

IOW it is just a bogus NULL pointer check, though it still would be nice
to have the issue fixed.  Care to send a patch removing it?

--
Bartlomiej Zolnierkiewicz
