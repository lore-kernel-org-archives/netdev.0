From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading
 (-git7 is ok)
Date: Tue, 13 Jan 2009 10:39:48 -0800
Message-ID: <20090113183948.GA21847@xw6200.broadcom.net>
References: <43805.1231672258@turing-police.cc.vt.edu>
 <20090111.040842.86784676.davem@davemloft.net>
 <1231676698.25018.147.camel@macbook.infradead.org>
 <20090111.133929.57600645.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "dwmw2@infradead.org" <dwmw2@infradead.org>,
	"Valdis.Kletnieks@vt.edu" <Valdis.Kletnieks@vt.edu>,
	"alessandro.suardi@gmail.com" <alessandro.suardi@gmail.com>,
	"jaswinderlinux@gmail.com" <jaswinderlinux@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4740 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751667AbZAMSkB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2009 13:40:01 -0500
In-Reply-To: <20090111.133929.57600645.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 11, 2009 at 01:39:29PM -0800, David Miller wrote:
> From: David Woodhouse <dwmw2@infradead.org>
> Date: Sun, 11 Jan 2009 12:24:58 +0000
> 
> > Other drivers will load the firmware later, at the time the device is
> > brought up. This means that even if you build the driver into the kernel
> > without its firmware, it can still request the firmware later, when you
> > try to start _using_ it. And when the file system is available.
> 
> For example, for mounting an NFS root using that device.... Oh, will I
> need an initramfs for that once you pull the firmware-in-kernel
> option?
> 
> To me, device probe is in fact the place to fail firmware discovery
> for networking devices.  Because such a failure can mean you can't
> mount your root filesystem.

David, is this the direction you want to take the fix?  I'm sitting on
a patch that elaborates on David Woodhouse's work which moves the
request_firmware call to tg3_open().  Before I posted it for comment,
I wanted to make sure the patch is moving in the right direction.

