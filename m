From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [PATCH] epoll: prevent missed events on EPOLL_CTL_MOD
Date: Wed, 2 Jan 2013 21:16:32 +0000
Message-ID: <20130102211632.GB17806@dcvr.yhbt.net>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <1356960060-1263-1-git-send-email-normalperson@yhbt.net>
 <1357065750.21409.12527.camel@edumazet-glaptop>
 <20130101210033.GA13255@dcvr.yhbt.net>
 <20130101211728.GA13380@dcvr.yhbt.net>
 <CA+55aFwP3Tvmfh23KDDXhB3k=RS8pNhqasw5vuBUHw4TxrakOQ@mail.gmail.com>
 <20130101235605.GA17168@dcvr.yhbt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Hans Verkuil <hans.verkuil@cisco.com>,
	Jiri Olsa <jolsa@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Hans de Goede <hdegoede@redhat.com>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andreas Voellmy <andreas.voellmy@yale.edu>,
	"Junchang(Jason) Wang" <junchang.wang@yale.edu>,
	Network Development <netdev@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dcvr.yhbt.net ([64.71.152.64]:42774 "EHLO dcvr.yhbt.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752702Ab3ABVQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jan 2013 16:16:33 -0500
Content-Disposition: inline
In-Reply-To: <20130101235605.GA17168@dcvr.yhbt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Wong <normalperson@yhbt.net> wrote:
> Linus Torvalds <torvalds@linux-foundation.org> wrote:
> > Please document the barrier that this mb() pairs with, and then give
> > an explanation for the fix in the commit message, and I'll happily
> > take it. Even if it's just duplicating the comments above the
> > wq_has_sleeper() function, except modified for the ep_modify() case.
> 
> Hopefully my explanation is correct and makes sense below,
> I think both effects of the barrier are needed

I noticed Linus accepted this already.  This should probably go to
stable, right?

>From ancient git history[1], it seems this bug exists for all
2.6 kernels:

	commit 424980a87e226d63af46579b2af16ec1b8d17e52
	Author: Davide Libenzi <davidel@xmailserver.org>
	Date:   Thu Nov 14 16:17:23 2002 -0800

	    [PATCH] epoll bits 0.46 ...

[1] - git://git.kernel.org/pub/scm/linux/kernel/git/tglx/history.git
