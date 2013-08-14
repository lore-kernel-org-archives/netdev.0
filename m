From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: Re: [PATCH 1/7] uio: add module owner to prevent inappropriate
 module unloading
Date: Wed, 14 Aug 2013 09:19:46 +0200
Message-ID: <20130814091946.2643a124@mitra.spranger.biz>
References: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
	<1376384922-8519-3-git-send-email-b.spranger@linutronix.de>
	<20130813174814.GE4098@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	"Hans J. Koch" <hjk@hansjkoch.de>,
	Holger Dengler <dengler@linutronix.de>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:53305 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759113Ab3HNHTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 03:19:50 -0400
In-Reply-To: <20130813174814.GE4098@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Tue, 13 Aug 2013 10:48:14 -0700
schrieb Greg Kroah-Hartman <gregkh@linuxfoundation.org>:

> On Tue, Aug 13, 2013 at 11:08:36AM +0200, Benedikt Spranger wrote:
> > If an UIO device is created by another driver (MFD for instance) it has to be
> > ensured that the MFD driver isn't removed while the UIO is still in use.
> 
> Shouldn't if the MFD driver is removed, the UIO device will be cleaned
> up and also removed?
That is part of the problem:

1) MFD driver creates platform device "uio_pdrv"
2) uio_pdrv creates "UIOX"
3) userspace opens "UIOX"
4) MFD driver unload (remove platform device "uio_pdrv")
5) userspace reads from "UIOX" --> crash

> You shouldn't need a module reference for this type of thing.
The driver uio_pdrv has no chance to recognize that the underlaying platform
device has gone.

Regards
    Benedikt Spranger
