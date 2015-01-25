From: Oleg <lego12239@yandex.ru>
Subject: Re: CONFIG_NF_CONNTRACK_PROCFS
Date: Sun, 25 Jan 2015 22:44:35 +0300
Message-ID: <20150125194435.GA12981@localhost>
References: <20150125055117.GA5586@localhost>
 <20150125112209.GD13167@breakpoint.cc>
Reply-To: Oleg <lego12239@yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward3m.cmail.yandex.net ([5.255.216.21]:53841 "EHLO
	forward3m.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755244AbbAYTyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 14:54:16 -0500
Received: from smtp1o.mail.yandex.net (smtp1o.mail.yandex.net [37.140.190.26])
	by forward3m.cmail.yandex.net (Yandex) with ESMTP id A25BE80907
	for <netdev@vger.kernel.org>; Sun, 25 Jan 2015 22:46:19 +0300 (MSK)
Received: from smtp1o.mail.yandex.net (localhost [127.0.0.1])
	by smtp1o.mail.yandex.net (Yandex) with ESMTP id 47C34DE27D3
	for <netdev@vger.kernel.org>; Sun, 25 Jan 2015 22:46:19 +0300 (MSK)
Content-Disposition: inline
In-Reply-To: <20150125112209.GD13167@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 25, 2015 at 12:22:09PM +0100, Florian Westphal wrote:
> Oleg <lego12239@yandex.ru> wrote:
> > net/netfilter/nf_conntrack procfs file is marked as obsolete in the recent
> > kernels. What's wrong with it? Or it's simply a new fashion to replace
> > simple file interface with anything else?
> 
> proc has several drawbacks vs. ctnetlink:
>  - not extensible

In the what way?
Sorry, but i think that limitations isn't in proc, but in a human fantasy.

>  - doesn't have ability to query for particular items

What about something like:

exec 3<>nf_conntrack; echo show tcp dport 12345 >&3; cat <&3
HERE_WE_GET_NEEDED_ENTRIES
exec 3<&-

?

>  - no add/delete support

What about simple:

echo add ENTRY > nf_conntrack
echo delete ENTRY > nf_conntrack

?

>  - no event notification (e.g. conntrack -E)

Florian, are you seriosly? What's wrong with simple:

cat nf_conntrack_event

?

Moreover, all things i have wrote save already existent scripts works.

May be i don't understand anything? Please correct me if so.

P.S. netlink is really cool thing, but i think we go in the wrong way.

-- 
Nemanov Oleg
