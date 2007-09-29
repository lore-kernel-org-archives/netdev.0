From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 5/5] net: Make AF_UNIX per network namespace safe.
Date: Sat, 29 Sep 2007 11:03:05 -0600
Message-ID: <m1abr58kvq.fsf@ebiederm.dsl.xmission.com>
References: <m1myv69tfu.fsf@ebiederm.dsl.xmission.com>
	<m1hcle9td8.fsf@ebiederm.dsl.xmission.com>
	<m1d4w29t98.fsf_-_@ebiederm.dsl.xmission.com>
	<m17ima9t52.fsf_-_@ebiederm.dsl.xmission.com>
	<m11wci9t3e.fsf_-_@ebiederm.dsl.xmission.com>
	<46FE73AC.40807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:60634 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756332AbXI2RDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 13:03:45 -0400
In-Reply-To: <46FE73AC.40807@trash.net> (Patrick McHardy's message of "Sat, 29
	Sep 2007 17:47:56 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> Eric W. Biederman wrote:
>> Because of the global nature of garbage collection, and because of the
>> cost of per namespace hash tables unix_socket_table has been kept
>> global.  With a filter added on lookups so we don't see sockets from
>> the wrong namespace.
>> 
>> Currently I don't fold the namesapce into the hash so multiple
>> namespaces using the same socket name will be guaranteed a hash
>> collision.
>
>
> That doesn't sound like a good thing :) Is there a reason for
> not avoiding the collisions?

Two reasons.  Minimizing the size of the changes to make review
easier, and I don't know if hash collisions are likely in practice
or if they matter.  I don't believe we can't physically collide and
have the same inode because we make a node in the filesystem.  The
abstract domain is local to linux and so people don't use it as much.

All of which boils down to.  I don't see it matter a heck of a lot
especially initially.  So I did the traditional unix thing and started
with a simple and stupid implementation.  But it didn't quite feel
right to me either so I documented it.

Whipping up a patch to take the namespace into account in mkname
doesn't look to hard though.

Eric
