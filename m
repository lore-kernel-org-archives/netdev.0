From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Summary lightweight tunnel discussion at NFWS
Date: Mon, 6 Jul 2015 15:03:49 +0200
Message-ID: <20150706130348.GA19361@pox.localdomain>
References: <1434689355-4088-3-git-send-email-roopa@cumulusnetworks.com>
 <20150703100023.GH26182@pox.localdomain>
 <5598CCF9.4090407@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ebiederm@xmission.com, rshearma@brocade.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:35808 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754569AbbGFNDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 09:03:52 -0400
Received: by wiga1 with SMTP id a1so228239181wig.0
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 06:03:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5598CCF9.4090407@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/04/15 at 11:21pm, roopa wrote:
> Thx. I have fixed this since,...did not realize it came in as part of this
> RFC series.
> >
> >Other than that I managed to rebase my changes onto yours and it
> >looks clean.
> Glad to know!. thanks Thomas. I had a few more changes (mostly cleanup/bug
> fixes, ipv6 support and mostly earlier feedback from you)
> in my local clone, pushed it to my github tree just now.

> This also tries to not use CONFIG_LWTUNNEL all over the place. I had it that
> way initially also because of fib struct members

The integration into the routing code looks much better now. Any
chance you can rebase your tree and squash it into logical
commits? I'm rebasing again onto yours and I think we should submit
all of this in a single series so everything can be reviewed in a
single thread.

> under #ifdef CONFIG_LWTUNNEL. (If we think at a later point that it is
> better to #ifdef CONFIG_LWTUNNEL fib struct members,
> I can bring some of that back in). And, Only control path (rtnetlink) for
> ipv6 mpls iptunnels has been tested.

All of this is only useful if distros enable this by default which
minimize the value of a config option quite a bit. I think what you
have your latest tree is a good balance.

> I have been thinking of moving lwtstate from rtable to struct dst_entry.
> I will also look at the dst_metadata.

I thought about the same. The introduction of dst_metadata makes
that a bit pointless because we don't want to store a pointer to the
tunnel metadata but allocate the metadata as a dst directly to avoid
the indirection. We need the separate code paths anyway until v6 and
v4 routing are merged so we would save very little while penalizing
everyone except rtable and fib6.
