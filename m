From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: How to grab a block of binary data w/out using ioctls?
Date: Tue, 24 Oct 2006 21:35:49 -0700
Message-ID: <20061024213549.92cbbeb0.randy.dunlap@oracle.com>
References: <453D61E8.8020400@candelatech.com>
	<20061023215448.f4f6c95a.randy.dunlap@oracle.com>
	<20061024050014.GC12506@havoc.gtf.org>
	<453ECB2C.3070202@candelatech.com>
	<20061025024718.GB23769@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:26003 "EHLO
	rgminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1422901AbWJYEeZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 00:34:25 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <20061025024718.GB23769@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Oct 2006 22:47:18 -0400 Jeff Garzik wrote:

> On Tue, Oct 24, 2006 at 07:25:48PM -0700, Ben Greear wrote:
> > From reading the Documentation/filesystems/sysfs.txt, it seems like
> > it is not recommended that one use sysfs for anything other than
> > very simple (and single) attributes.
> > 
> > If you know of a piece of code that actually passes back a struct or
> > other binary blob of data, please point me to it so I can learn from it.
> 
> Please grep for sysfs_create_bin_file, you will find plenty of examples.

Hm, I thought that sysfs binary files were supposed to be
for "transparent" blobs of data, not for structured data.
E.g., a "firmware" blob would be OK.

And I'm looking at current users.  ISTM that this one:

arch/ppc/syslib/mv64x60.c:2443:	sysfs_create_bin_file(&mv64xxx_device.dev.kobj, &mv64xxx_hs_reg_attr);

in its sysfs read function returns a string (binary data converted
to a string) instead of returning binary data.  Or did I misread it?
or misunderstand sysfs binary data?

---
~Randy
