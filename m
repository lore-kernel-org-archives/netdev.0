From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: sysfs class/net/ problem
Date: Wed, 02 Jun 2010 21:25:32 +0200
Message-ID: <1275506732.3915.41.camel@jlt3.sipsolutions.net>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	 <20100602154608.GB12361@kroah.com>
	 <1275493693.3915.12.camel@jlt3.sipsolutions.net>
	 <m1ljaxxvcj.fsf@fess.ebiederm.org>
	 <1275495677.3915.16.camel@jlt3.sipsolutions.net>
	 <m14ohlxu51.fsf@fess.ebiederm.org>
	 <1275498007.3915.20.camel@jlt3.sipsolutions.net>
	 <m1ocftwdp7.fsf@fess.ebiederm.org>
	 <1275501157.3915.22.camel@jlt3.sipsolutions.net>
	 <m1y6exux6x.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:34001 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932597Ab0FBTZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 15:25:34 -0400
In-Reply-To: <m1y6exux6x.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-02 at 11:05 -0700, Eric W. Biederman wrote:

> My current hypothesis is something is causing us to try and delete
> the symlink from the wrong namespace, so we just skip that part of it.

Hmm... ok:

[   70.338274] create link wlan2 ns=(null)
...
[   71.881775] delete link wlan2 ns=(null)
[   71.881777] hash_and_remove ffff88001f9563c0, (null), wlan2
[   71.881782] sd=ffff88001ce2d9c0, sdns=ffffffff8271c260

and thus we skip sysfs_remove_one() in sysfs_hash_and_remove() because
sysfs_find_dirent() return an sd with a different ns than we passed in.
Why is the ns we pass in NULL, shouldn't it be init_ns?

johannes

