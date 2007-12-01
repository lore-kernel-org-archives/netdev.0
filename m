From: Mark Lord <lkml@rtr.ca>
Subject: namespace support requires network modules to say "GPL"
Date: Sat, 01 Dec 2007 08:10:17 -0500
Message-ID: <47515D39.9030900@rtr.ca>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Greg KH <greg@kroah.com>,
	Tejun Heo <htejun@gmail.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, cornelia.huck@de.ibm.com,
	stern@rowland.harvard.edu, kay.sievers@vrfy.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtr.ca ([76.10.145.34]:3712 "EHLO mail.rtr.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751229AbXLANKT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 08:10:19 -0500
In-Reply-To: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Now that we have network namespace support merged it is time to
> revisit the sysfs support so we can remove the dependency on !SYSFS.
...

Now that the namespace updates are part of 2.6.24,
there is a major inconsistency in network EXPORT_SYMBOLs.

It used to be that an external network module could get away without
having to add a MODULE_LICENSE("GPL*") line to the source.

In support of that, common networking functions (still) use EXPORT_SYMBOL()
rather than the more restrictive EXPORT_SYMBOL_GPL().

Eg.  register_netdev(), sk_alloc(), __dev_get_by_name().

But now, none of those three are actually usable by default,
because they all require "init_net", which is EXPORT_SYMBOL_GPL().

So.. It appears that one of three things should really happen next:

1) Change the other exports to also be EXPORT_SYMBOL_GPL.

2) Have register_netdev, sk_alloc, and __dev_get_by_name default
to using init_net when NULL is specified in the namespace field.

or 

3) Change init_net to be EXPORT_SYMBOL_GPL.

Right now, things are just a bit inconsistent, and it's not clear
whether the namespace changes intended this consequence or not.

Cheers

(as for me, I think all kernel modules are GPL, whether they have
 the MODULE_LICENSE line or not, so flames to /dev/null on that).
