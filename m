From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [patch, -rc5-mm1] lock validator: remove softirq.c WARN_ON
Date: Tue, 30 May 2006 18:05:30 +0200
Message-ID: <1149005130.3636.75.camel@laptopd505.fenrus.org>
References: <20060530022925.8a67b613.akpm@osdl.org>
	 <447C261E.1090202@gmail.com> <20060530115545.GA7025@elte.hu>
	 <20060530160024.GA8987@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Jiri Slaby <jirislaby@gmail.com>,
	Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, netdev@vger.kernel.org, alan@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:44961 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751525AbWE3QFs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 May 2006 12:05:48 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060530160024.GA8987@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-05-30 at 20:00 +0400, Alexey Kuznetsov wrote:
> Hello!
> 
> > ok, that WARN_ON is over-eager. Fix is below:
> 
> Nevertheless, I cannot figure out what's happening here.
> 
> This local_bh_disable() is called right after schedule().
> No way irqs can be disabled there. What is wrong?
> 
> 
> static void netlink_table_grab(void)
> {
>         write_lock_bh(&nl_table_lock);

well it could be this one as well...

> 
>         if (atomic_read(&nl_table_users)) {


