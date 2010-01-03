From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2: unsupported chip type 0xff failure
Date: Sun, 3 Jan 2010 11:13:30 -0800
Message-ID: <20100103111330.06df6c50@nehalam>
References: <20100102224858.GA17023@gregory-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Gregory Petrosyan <gregory.petrosyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52832 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751926Ab0ACTNg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jan 2010 14:13:36 -0500
In-Reply-To: <20100102224858.GA17023@gregory-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 3 Jan 2010 01:48:58 +0300
Gregory Petrosyan <gregory.petrosyan@gmail.com> wrote:

> I've got an HP ProBook 5310m laptop with Marvell Ethernet controller. sky2 reports
> 
> [14252.318867] sky2 driver version 1.23
> [14252.318904] sky2 0000:03:00.0: setting latency timer to 64
> [14252.318951] sky2 0000:03:00.0: unsupported chip type 0xff
> [14252.318960] sky2: probe of 0000:03:00.0 failed with error -95
> 
> (this is captured after 'modprobe -r' + 'modprobe') and I've seen it working
> only 1 time (probably after a reboot).

The chip id is one of the first things read from the device. If the PCI
read gets an error, then the value is all-ones.

The issue is not directly in the driver, but with the power control for
that device. 

Try the latest kernel (even 2.6.33-rc2) to make sure the problem isn't
already fixed. 

-- 
