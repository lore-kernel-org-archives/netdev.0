From: David Miller <davem@davemloft.net>
Subject: Re: net: rtnetlink: support specifying device flags on device
 creation
Date: Sat, 27 Feb 2010 02:51:28 -0800 (PST)
Message-ID: <20100227.025128.186425822.davem@davemloft.net>
References: <20100226163449.11434.13013.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39722
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965301Ab0B0KvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 05:51:11 -0500
In-Reply-To: <20100226163449.11434.13013.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 26 Feb 2010 17:34:49 +0100 (MET)

> The following patches add support to specify the device flags (like UP) when
> creating a new device through rtnl_link. This requires to surpress netlink
> notifications until the device is fully configured in order to not confuse
> userspace when changing the flags fails and registration has to be undone.
> Once the device is configured, a single NEWLINK message with the full state
> is sent.
> 
> The individual patch changelogs describe the necessary changes in more detail.

All applied, but two things:

1) This patch set was harder to review because there were no
   default initializations of the new enumeration you added
   to struct netdev.

   I know RTNL_LINK_INITIALIZED is probably zero by C enumeration
   rules, and the zeroing out of new netdev objects gives us this,
   but I only figured that out after some time.

   It deserved at least a commit message mention in patch #2.

2) I would really appreciate you forming your patch postings
   properly.  I have to edit them every single time

   You put the whole output of "git show" or "git format-patch" into
   your email body.  That doesn't work, we don't want all of those
   commit ID etc. lines in there.  It also causes every line of your
   commit messages to be indented by 4 spaces.

   Your email body should just contain the unindented commit message
   and the signoffs, then the patch itself.

   Your Subject lines are also not setup properly.  Because the
   "net X/N:" thing isn't in [] brackets, it ends up in the
   commit message header lines when I feed your emails to
   "git am".

   All of this could be avoided if you used git send-email but
   I realize that a lot of people dislike that for one reason
   or another (myself included), but if you're going to compose
   the emails by hand you ought to make it look the same (syntax
   wise) as what git send-email would have emitted.

Thanks!
