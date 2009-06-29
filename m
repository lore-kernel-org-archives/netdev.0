From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 1/2] net: adding memory barrier to the poll and receive
 callbacks
Date: Mon, 29 Jun 2009 10:36:30 -0700 (PDT)
Message-ID: <alpine.DEB.1.10.0906291033140.30244@makko.or.mcafeemobile.com>
References: <20090629140434.GE3845@jolsa.lab.eng.brq.redhat.com> <20090629141445.GF3845@jolsa.lab.eng.brq.redhat.com> <alpine.DEB.1.10.0906290826300.29966@makko.or.mcafeemobile.com> <20090629173217.GC2742@ami.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jiri Olsa <jolsa@redhat.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, oleg@redhat.com, eric.dumazet@gmail.com
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:44728 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753064AbZF2Ri0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 13:38:26 -0400
Received: from makko.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.26 ESMTP Server]
	id <S2F47CF> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Mon, 29 Jun 2009 13:38:05 -0400
In-Reply-To: <20090629173217.GC2742@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Jun 2009, Jarek Poplawski wrote:

> > I think Oleg already said this, but you can use directly poll_wait() 
> > without adding another abstraction, and the compiler will drop the double 
> > check for you:
> 
> I think Oleg told about cosmetics and let Jiri to choose. I'd only
> add it's not mainly about optimization, but easy showing the main
> difference, of course depending on taste.

We already have a universally used function to do that, and that's 
poll_wait().
That code (adding an extra __poll_wait()) was entirely about 
optimizations (otherwise why not use the existing poll_wait()?), so if 
the optimization does not actually take place, IMO it's better to not add 
an extra API.



- Davide


