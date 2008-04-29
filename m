From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [Bug 10575] New: WARNING: at mm/slub.c:2444
Date: Tue, 29 Apr 2008 22:39:13 +0300
Message-ID: <48177961.3030204@cs.helsinki.fi>
References: <bug-10575-27@http.bugzilla.kernel.org/>	<20080429082231.2c5470ff.akpm@linux-foundation.org>	<481773A6.5050507@trash.net> <20080429123741.bce81cf8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, htmldeveloper@gmail.com,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	clameter@sgi.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38878 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608AbYD2TlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 15:41:05 -0400
In-Reply-To: <20080429123741.bce81cf8.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> Sorry, I confused it with a similar-looking USB trace.  Pekka added some
> additional debug at that site which might help here - it will tell us the
> name of the slab cache:
> 
> void kmem_cache_destroy(struct kmem_cache *s)
> {
> 	down_write(&slub_lock);
> 	s->refcount--;
> 	if (!s->refcount) {
> 		list_del(&s->list);
> 		up_write(&slub_lock);
> 		if (kmem_cache_close(s)) {
> 			printk(KERN_ERR "SLUB %s: %s called for cache that "
> 				"still has objects.\n", s->name, __func__);
> 			dump_stack();
> 		}
> 		sysfs_slab_remove(s);
> 	} else
> 		up_write(&slub_lock);
> }
> 			
> that was merged into mainline yesterday.

Christoph added even nicer debugging code that dumps the objects in the 
cache:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=33b12c38134e95e5afa73214af6f49abd7b8418e
