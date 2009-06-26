From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Fri, 26 Jun 2009 11:12:15 -0700 (PDT)
Message-ID: <alpine.DEB.1.10.0906261111230.16400@makko.or.mcafeemobile.com>
References: <20090625122545.GA3625@jolsa.lab.eng.brq.redhat.com> <20090625122416.GA23613@redhat.com> <alpine.DEB.1.10.0906251827510.9517@makko.or.mcafeemobile.com> <4A442B65.8040701@gmail.com> <alpine.DEB.1.10.0906251858520.9517@makko.or.mcafeemobile.com>
 <4A443033.8060401@gmail.com> <alpine.DEB.1.10.0906251947530.9517@makko.or.mcafeemobile.com> <20090626135742.GB3845@redhat.com> <alpine.DEB.1.10.0906261018580.16400@makko.or.mcafeemobile.com> <20090626145027.GA6534@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Olsa <jolsa@redhat.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	Tejun Heo <htejun@gmail.com>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:54969 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169AbZFZSQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 14:16:15 -0400
Received: from makko.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.26 ESMTP Server]
	id <S2F3DE8> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Fri, 26 Jun 2009 14:15:53 -0400
In-Reply-To: <20090626145027.GA6534@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Jun 2009, Oleg Nesterov wrote:

> Perhaps we can add
> 
> 	void sock_poll_wait(struct file *file, struct sock *sk, poll_table *pt)
> 	{
> 		if (pt) {
> 			poll_wait(file, sk->sk_sleep, pt);
> 			/*
> 			 * fat comment
> 			 */
> 			smp_mb(); // or smp_mb__after_unlock();
> 		}
> 	}

That'd be fine IMHO. Are DaveM and Eric OK?


- Davide


