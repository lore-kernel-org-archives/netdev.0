From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 1/7] uio: add module owner to prevent inappropriate module
 unloading
Date: Thu, 15 Aug 2013 10:18:17 +0200
Message-ID: <520C8EC9.6040603@linutronix.de>
References: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de> <1376384922-8519-3-git-send-email-b.spranger@linutronix.de> <20130813174814.GE4098@kroah.com> <20130814091946.2643a124@mitra.spranger.biz> <20130814163311.GB7208@kroah.com> <20130815084221.3339142f@mitra.spranger.biz> <20130815065936.GA13320@kroah.com> <20130815092753.5a23810b@mitra.spranger.biz> <20130815080901.GC7080@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Benedikt Spranger <b.spranger@linutronix.de>,
	netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	"Hans J. Koch" <hjk@hansjkoch.de>,
	Holger Dengler <dengler@linutronix.de>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:32988 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311Ab3HOISU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 04:18:20 -0400
In-Reply-To: <20130815080901.GC7080@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2013 10:09 AM, Greg Kroah-Hartman wrote:
> Do you have a specific example of an in-tree UIO driver that has this
> problem that I can look at to try to understand this better?

grep for "uio_pdrv" and you find a few devices in arm and sh tree. Each
one is created once at boot time and never removed. With mfd the device
can be removed.
If you look now at uio_write() then you will notice that it will
deference idev->info->irqcontrol but once the device is gone the memory
starting at info is gone, not to mention the code behind irqcontrol.

> Still confused,
> 
> greg k-h

Sebastian
