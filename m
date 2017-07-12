From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] get_compat_msghdr(): get rid of field-by-field copyin
Date: Tue, 11 Jul 2017 20:25:14 -0700 (PDT)
Message-ID: <20170711.202514.815304234636661456.davem@davemloft.net>
References: <20170708182100.GR10672@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46846 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753230AbdGLDZP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 23:25:15 -0400
In-Reply-To: <20170708182100.GR10672@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Sat, 8 Jul 2017 19:21:00 +0100

> There are 3 commits in vfs.git#misc.compat I hadn't pushed to Linus yet;
> they touch net/* and I'd like to see at least "no objections" from networking
> folks before asking to pull that; all of those are about getting rid of
> field-by-field copyin.  Please, review and comment.
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

That weird sparc64 regression concerns me.

The commit referenced in that discussion:

d9e968cb9f849770288f5fde3d8d3a5f7e339052 ("getrlimit()/setrlimit(): move compat to native")

looks harmless, or if there is a bug in there I can't see it.

But whatever it is, that same problem could be hiding in some of these
other transformations as well.

I think the bug might be that we are corrupting the user's stack
somehow.  But the two user copies in that commit look perfectly fine
to my eyes.

There shouldn't be any padding in that compat_rlimit structure, so
it's not like we're copying extra bytes.  Well, we'd be exposing
kernel stack memory if that were the case.

Color me stumped, but cautious about ACK'ing these networking
compat changes.
