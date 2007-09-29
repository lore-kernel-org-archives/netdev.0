From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/5] net: Make AF_UNIX per network namespace safe.
Date: Sat, 29 Sep 2007 19:50:14 +0200
Message-ID: <46FE9056.1070400@trash.net>
References: <m1myv69tfu.fsf@ebiederm.dsl.xmission.com>	<m1hcle9td8.fsf@ebiederm.dsl.xmission.com>	<m1d4w29t98.fsf_-_@ebiederm.dsl.xmission.com>	<m17ima9t52.fsf_-_@ebiederm.dsl.xmission.com>	<m11wci9t3e.fsf_-_@ebiederm.dsl.xmission.com>	<46FE73AC.40807@trash.net> <m1abr58kvq.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53147 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752017AbXI2Rui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 13:50:38 -0400
In-Reply-To: <m1abr58kvq.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
>>>Currently I don't fold the namesapce into the hash so multiple
>>>namespaces using the same socket name will be guaranteed a hash
>>>collision.
>>
>>
>>That doesn't sound like a good thing :) Is there a reason for
>>not avoiding the collisions?
> 
> 
> Two reasons.  Minimizing the size of the changes to make review
> easier, and I don't know if hash collisions are likely in practice
> or if they matter.  I don't believe we can't physically collide and
> have the same inode because we make a node in the filesystem.  The
> abstract domain is local to linux and so people don't use it as much.
> 
> All of which boils down to.  I don't see it matter a heck of a lot
> especially initially.  So I did the traditional unix thing and started
> with a simple and stupid implementation.  But it didn't quite feel
> right to me either so I documented it.
> 
> Whipping up a patch to take the namespace into account in mkname
> doesn't look to hard though.


It doesn't look like it would increase patch size significantly
(about 4 more changed lines), but it could of course be done in
a follow-up patch.

