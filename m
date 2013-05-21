From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] rcu: fix a race in hlist_nulls_for_each_entry_rcu macro
Date: Tue, 21 May 2013 14:42:34 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7242@saturn3.aculab.com>
References: <519B38EC.90401@yandex-team.ru> <AE90C24D6B3A694183C094C60CF0A2F6026B7241@saturn3.aculab.com> <519B6099.1080403@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Dipankar Sarma" <dipankar@in.ibm.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	<zhmurov@yandex-team.ru>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>,
	"James Morris" <jmorris@namei.org>,
	"Hideaki YOSHIFUJI" <yoshfuji@linux-ipv6.org>,
	"Patrick McHardy" <kaber@trash.net>
To: "Roman Gushchin" <klamm@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57529 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752525Ab3EUNnG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 09:43:06 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 01105-03 for <netdev@vger.kernel.org>;
 Tue, 21 May 2013 14:43:01 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <519B6099.1080403@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> -#define hlist_nulls_first_rcu(head) \
> >> -	(*((struct hlist_nulls_node __rcu __force **)&(head)->first))
> >> +#define hlist_nulls_first_rcu(head)			\
> >> +	(*((struct hlist_nulls_node __rcu __force **)	\
> >> +	   &((volatile typeof(*head) *)head)->first))
> >
> > I'd have thought it would be better to change hlist_nulls_first_rcu().
> 
> It's exactly what I suggest. May be I miss something? Please, clarify.

Gah - chasing through too many defines in too many header files!
Actually making the 'head' structure have volatile pointers
might be better.
Possibly in struct hlist_nulls_node itself.
There are toooo many casts for sanity :-)

	David
