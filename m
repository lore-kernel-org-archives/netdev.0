From: Patrick McHardy <kaber@trash.net>
Subject: Re: net: rtnetlink: support specifying device flags on device creation
Date: Mon, 01 Mar 2010 16:24:23 +0100
Message-ID: <4B8BDC27.2060803@trash.net>
References: <20100226163449.11434.13013.sendpatchset@x2.localnet> <20100227.025128.186425822.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57914 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033Ab0CAPYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Mar 2010 10:24:25 -0500
In-Reply-To: <20100227.025128.186425822.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Fri, 26 Feb 2010 17:34:49 +0100 (MET)
> 
>> The following patches add support to specify the device flags (like UP) when
>> creating a new device through rtnl_link. This requires to surpress netlink
>> notifications until the device is fully configured in order to not confuse
>> userspace when changing the flags fails and registration has to be undone.
>> Once the device is configured, a single NEWLINK message with the full state
>> is sent.
>>
>> The individual patch changelogs describe the necessary changes in more detail.
> 
> All applied, but two things:
> 
> 1) This patch set was harder to review because there were no
>    default initializations of the new enumeration you added
>    to struct netdev.
> 
>    I know RTNL_LINK_INITIALIZED is probably zero by C enumeration
>    rules, and the zeroing out of new netdev objects gives us this,
>    but I only figured that out after some time.
> 
>    It deserved at least a commit message mention in patch #2.

Agreed. The reason to use the value 0 for RTNL_LINK_INITIALIZED
was that it avoids touching drivers that can register netdevices
through non rtnl_link paths, like bonding, ifb or dummy.

> 2) I would really appreciate you forming your patch postings
>    properly.  I have to edit them every single time
> 
>    You put the whole output of "git show" or "git format-patch" into
>    your email body.  That doesn't work, we don't want all of those
>    commit ID etc. lines in there.  It also causes every line of your
>    commit messages to be indented by 4 spaces.
> 
>    Your email body should just contain the unindented commit message
>    and the signoffs, then the patch itself.
> 
>    Your Subject lines are also not setup properly.  Because the
>    "net X/N:" thing isn't in [] brackets, it ends up in the
>    commit message header lines when I feed your emails to
>    "git am".
> 
>    All of this could be avoided if you used git send-email but
>    I realize that a lot of people dislike that for one reason
>    or another (myself included), but if you're going to compose
>    the emails by hand you ought to make it look the same (syntax
>    wise) as what git send-email would have emitted.

I'll either switch to git-send-email or make sure my script
works properly with git-am.
