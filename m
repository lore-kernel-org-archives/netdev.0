From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: tun: add tun_flags, owner, group attributes in sysfs
Date: Tue, 05 May 2009 23:18:33 +0100
Message-ID: <1241561913.20057.40.camel@macbook.infradead.org>
References: <1241433136.6126.70.camel@macbook.infradead.org>
	 <49FEC52E.6070501@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mark McLoughlin <markmc@redhat.com>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33121 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469AbZEEWSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 18:18:35 -0400
In-Reply-To: <49FEC52E.6070501@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-05-04 at 14:36 +0400, Michael Tokarev wrote:
> David Woodhouse wrote:
> > This patch adds three attribute files in /sys/class/net/$dev/ for tun
> > devices; allowing userspace to obtain the information which TUNGETIFF
> > offers, and more, but without having to attach to the device in question
> > (which may not be possible if it's in use).
> > 
> []
> > +static DEVICE_ATTR(tun_flags, 0444, tun_show_flags, NULL);
> > +static DEVICE_ATTR(owner, 0444, tun_show_owner, NULL);
> > +static DEVICE_ATTR(group, 0444, tun_show_group, NULL);
> 
> Is there any reason why those files are not writable?
> 
> I understand flags one, sorta (but it is still useful to
> be able to change some flags, like persistent, while it's
> running), but for owner/group - it's just an integer that's
> used to check permissions for ioctl, and can be set in sysfs
> just fine.  I think anyway.

I did think about it, but didn't see the point. There's little benefit
in being able to write owner/group through sysfs, and it's non-trivial
to get the permissions right.

You can currently change owner/group if you can attach to the device...
and you can attach to the device if you're _already_ the appropriate
uid/gid, or if you have CAP_NET_ADMIN. 

We can't make opens for write fail, as far as I'm aware -- the best we
could do is to reproduce the permissions check in the sysfs set
function, and return -EPERM to the _write_, which doesn't really fill me
with joy.

Being able to mark a device as non-persistent through sysfs while it's
open would be cute, I suppose -- but not cute enough that it's worth
having to deal with the case of marking it non-persistent that way while
it's _not_ open, which means it needs to disappear as soon as you write
the flags variable...

On the whole, it seemed better just to have them read-only. That's all
we really need, after all.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

