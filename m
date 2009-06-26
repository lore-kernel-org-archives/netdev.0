From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Thu, 25 Jun 2009 19:04:04 -0700 (PDT)
Message-ID: <alpine.DEB.1.10.0906251858520.9517@makko.or.mcafeemobile.com>
References: <20090625122545.GA3625@jolsa.lab.eng.brq.redhat.com> <20090625122416.GA23613@redhat.com> <alpine.DEB.1.10.0906251827510.9517@makko.or.mcafeemobile.com> <4A442B65.8040701@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1480592630-1245981844=:9517"
Cc: Oleg Nesterov <oleg@redhat.com>, Jiri Olsa <jolsa@redhat.com>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	Tejun Heo <htejun@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:59704 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752293AbZFZCId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 22:08:33 -0400
Received: from makko.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.26 ESMTP Server]
	id <S2F3B19> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Thu, 25 Jun 2009 22:08:19 -0400
In-Reply-To: <4A442B65.8040701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1480592630-1245981844=:9517
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 26 Jun 2009, Eric Dumazet wrote:

> Davide Libenzi a écrit :
> > On Thu, 25 Jun 2009, Oleg Nesterov wrote:
> > 
> >> Can't really comment this patch, except this all looks reasonable to me.
> >> Add more CCs.
> > 
> > While this can work, IMO it'd be cleaner to have the smp_mb() moved from 
> > fs/select.c to the ->poll() function.
> > Having a barrier that matches another one in another susbsystem, because 
> > of the special locking logic of such subsystem, is not too shiny IMHO.
> > 
> 
> Yes but barrier is necessary only if add_wait_queue() was actually called, and __pollwait()
> does this call.
> 
> Adding a plain smp_mb() in tcp_poll() for example would slowdown select()/poll() with NULL
> timeout.

Do you think of it as good design adding an MB on a subsystem, because of 
the special locking logic of another one?
The (eventual) slowdown, IMO can be argued sideways, by saying that 
non-socket users will pay the price for their polls.



- Davide


--8323329-1480592630-1245981844=:9517--
