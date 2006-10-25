From: Jeff Garzik <jeff@garzik.org>
Subject: Re: How to grab a block of binary data w/out using ioctls?
Date: Wed, 25 Oct 2006 00:46:21 -0400
Message-ID: <20061025044621.GA32486@havoc.gtf.org>
References: <453D61E8.8020400@candelatech.com> <20061023215448.f4f6c95a.randy.dunlap@oracle.com> <20061024050014.GC12506@havoc.gtf.org> <453ECB2C.3070202@candelatech.com> <20061025024718.GB23769@havoc.gtf.org> <20061024213549.92cbbeb0.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:43749 "EHLO havoc.gtf.org")
	by vger.kernel.org with ESMTP id S1422966AbWJYEqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 00:46:23 -0400
To: Randy Dunlap <randy.dunlap@oracle.com>
Content-Disposition: inline
In-Reply-To: <20061024213549.92cbbeb0.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 24, 2006 at 09:35:49PM -0700, Randy Dunlap wrote:
> > 
> > Please grep for sysfs_create_bin_file, you will find plenty of examples.
> 
> Hm, I thought that sysfs binary files were supposed to be
> for "transparent" blobs of data, not for structured data.
> E.g., a "firmware" blob would be OK.

Depends.  Normally ASCII is greatly preferred, but passing in/out big
data structures can be a huge pain, thunking to/from ASCII.


> And I'm looking at current users.  ISTM that this one:
> 
> arch/ppc/syslib/mv64x60.c:2443:	sysfs_create_bin_file(&mv64xxx_device.dev.kobj, &mv64xxx_hs_reg_attr);
> 
> in its sysfs read function returns a string (binary data converted
> to a string) instead of returning binary data.  Or did I misread it?
> or misunderstand sysfs binary data?

Yeah, that one shouldn't be using _bin_

	Jeff



