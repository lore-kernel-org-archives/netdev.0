From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Fri, 26 Jun 2009 11:17:38 -0700 (PDT)
Message-ID: <20090626.111738.141246987.davem@davemloft.net>
References: <alpine.DEB.1.10.0906261018580.16400@makko.or.mcafeemobile.com>
	<20090626145027.GA6534@redhat.com>
	<alpine.DEB.1.10.0906261111230.16400@makko.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oleg@redhat.com, eric.dumazet@gmail.com, jolsa@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, htejun@gmail.com
To: davidel@xmailserver.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46575
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753169AbZFZSRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 14:17:33 -0400
In-Reply-To: <alpine.DEB.1.10.0906261111230.16400@makko.or.mcafeemobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Davide Libenzi <davidel@xmailserver.org>
Date: Fri, 26 Jun 2009 11:12:15 -0700 (PDT)

> On Fri, 26 Jun 2009, Oleg Nesterov wrote:
> 
>> Perhaps we can add
>> 
>> 	void sock_poll_wait(struct file *file, struct sock *sk, poll_table *pt)
>> 	{
>> 		if (pt) {
>> 			poll_wait(file, sk->sk_sleep, pt);
>> 			/*
>> 			 * fat comment
>> 			 */
>> 			smp_mb(); // or smp_mb__after_unlock();
>> 		}
>> 	}
> 
> That'd be fine IMHO. Are DaveM and Eric OK?

No objections from me.
