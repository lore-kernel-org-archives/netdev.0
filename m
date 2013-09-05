From: Dave Jones <davej@redhat.com>
Subject: question about __udp6_lib_err usage of __udp6_lib_lookup
Date: Wed, 4 Sep 2013 22:44:34 -0400
Message-ID: <20130905024434.GA8219@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59806 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756565Ab3IECom (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 22:44:42 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r852ifjn010919
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 4 Sep 2013 22:44:41 -0400
Received: from gelk.kernelslacker.org (ovpn-113-166.phx2.redhat.com [10.3.113.166])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r852iZ7A012976
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 4 Sep 2013 22:44:41 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.7/8.14.7) with ESMTP id r852iYn3011543
	for <netdev@vger.kernel.org>; Wed, 4 Sep 2013 22:44:34 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.7/8.14.7/Submit) id r852iYQp011540
	for netdev@vger.kernel.org; Wed, 4 Sep 2013 22:44:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__udp6_lib_lookup's prototype is ...

struct sock *__udp6_lib_lookup(struct net *net,
                                      const struct in6_addr *saddr, __be16 sport,
                                      const struct in6_addr *daddr, __be16 dport,
                                      int dif, struct udp_table *udptable)

But the usage in __udp6_lib_err is...

 521         sk = __udp6_lib_lookup(dev_net(skb->dev), daddr, uh->dest,
 522                                saddr, uh->source, inet6_iif(skb), udptable);

With the source/dest addr/port arguments swapped. Is this intentional ?

	Dave
