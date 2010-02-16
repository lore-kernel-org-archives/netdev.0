From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [net-next PATCH v4 0/3] net: reserve ports for applications using fixed port
Date: Tue, 16 Feb 2010 20:04:33 +0200
Message-ID: <201002162004.33533.opurdila@ixiacom.com>
References: <1266271241-6293-1-git-send-email-opurdila@ixiacom.com> <m1sk916qkv.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Amerigo Wang <amwang@redhat.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:29825 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933153Ab0BPSJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 13:09:01 -0500
In-Reply-To: <m1sk916qkv.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 16 February 2010 19:25:04 you wrote:

> I don't like the /proc interface for this.  That is certainly not the
> format I would choose for a bitmap.  The way you have described this
> it looks like you are a set of different individual values instead of
> one large value.  History says one value per file is the ideal in a
> user space facing interface.  Intuitively I would not know how to
> change your new proc interface after catting the file.  The classic
> read the file tweak the value and write the new value back will not
> work.
> 
> Also we already have a common function for dealing with bitmaps
> in /proc.  bitmap_parse_user.  Used in /proc/irq/NNN/smp_affinity
> among other places.
> 
> So can you please use bitmap_parse_user, or break this up into
> 64k individual files that we can set individually?
> 

Hi Eric, thanks for going over this.

The use case (large bitmaps/lists) is different enough from what we have today 
(small bitmaps) and that is why I think that we need this new interface. 

If I get bitmap_parse_user correctly, for a 64k bitmap it expects a 2K comma 
separated values. That is not the most intuitively way for the user to set a 
list of ports he wants to reserve. 

Using 64K files has the same practical issues (the user would have to cat all 
64K files to determine which ports are reserved) plus it has issues caused by 
the large number of files: significant memory overhead and also significant time 
for registering those files.

If this new interface is unacceptable I would rather go with a setsockopt 
approach, since either of the above approaches are more like machine friendly  
instead of user friendly.
