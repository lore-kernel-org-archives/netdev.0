From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH] epoll: prevent missed events on EPOLL_CTL_MOD
Date: Wed, 02 Jan 2013 14:08:31 -0800
Message-ID: <1357164511.21409.18486.camel@edumazet-glaptop>
References: <20121228014503.GA5017@dcvr.yhbt.net>
	 <1356960060-1263-1-git-send-email-normalperson@yhbt.net>
	 <1357065750.21409.12527.camel@edumazet-glaptop>
	 <20130101210033.GA13255@dcvr.yhbt.net>
	 <20130101211728.GA13380@dcvr.yhbt.net>
	 <CA+55aFwP3Tvmfh23KDDXhB3k=RS8pNhqasw5vuBUHw4TxrakOQ@mail.gmail.com>
	 <20130101235605.GA17168@dcvr.yhbt.net>
	 <1357148750.21409.17169.camel@edumazet-glaptop>
	 <20130102184010.GA21780@dcvr.yhbt.net>
	 <1357153416.21409.17488.camel@edumazet-glaptop>
	 <20130102193227.GA13566@dcvr.yhbt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
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
To: Eric Wong <normalperson@yhbt.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:48456 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635Ab3ABWIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2013 17:08:34 -0500
In-Reply-To: <20130102193227.GA13566@dcvr.yhbt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-02 at 19:32 +0000, Eric Wong wrote:

> That modification in ep_send_events_proc() is protected by ep->mtx
> (as is ep_modify()), though.  Maybe there are other places, but I
> don't see it.

Yes, and using a mutex for protecting this field while its read from
interrupt context (so without mutex synch help) is why there were races.

Some users rely on barriers included in spin_lock/spin_unlock, others in
explicit barriers, or before your patch pure luck.
