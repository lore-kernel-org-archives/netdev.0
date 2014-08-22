From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next v2] ipv4: Restore accept_local behaviour in
 fib_validate_source()
Date: Fri, 22 Aug 2014 23:07:42 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1408222303460.7852@ja.home.ssi.bg>
References: <1408259994-31458-1-git-send-email-sebastien.barre@uclouvain.be>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-432535614-1408738085=:7852"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: =?UTF-8?Q?S=C3=A9bastien_Barr=C3=A9?=
	<sebastien.barre@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:41229 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751316AbaHVUJU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Aug 2014 16:09:20 -0400
In-Reply-To: <1408259994-31458-1-git-send-email-sebastien.barre@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-432535614-1408738085=:7852
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Sun, 17 Aug 2014, Sébastien Barré wrote:

> Commit 7a9bc9b81a5b ("ipv4: Elide fib_validate_source() completely when possible.")
> introduced a short-circuit to avoid calling fib_validate_source when not
> needed. That change took rp_filter into account, but not accept_local.
> This resulted in a change of behaviour: with rp_filter and accept_local
> off, incoming packets with a local address in the source field should be
> dropped.
> 
> Here is how to reproduce the change pre/post 7a9bc9b81a5b commit:
> -configure the same IPv4 address on hosts A and B.
> -try to send an ARP request from B to A.
> -The ARP request will be dropped before that commit, but accepted and answered
> after that commit.
> 
> This adds a check for ACCEPT_LOCAL, to maintain full
> fib validation in case it is 0. We also leave __fib_validate_source() earlier
> when possible, based on the same check as fib_validate_source(), once the
> accept_local stuff is verified.

	I remember there was related change for docs,
may be commit c801e3cc1925e0 should be reverted ?

> Cc: Gregory Detal <gregory.detal@uclouvain.be>
> Cc: Christoph Paasch <christoph.paasch@uclouvain.be>
> Cc: Hannes Frederic Sowa <hannes@redhat.com>
> Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Signed-off-by: Sébastien Barré <sebastien.barre@uclouvain.be>

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-432535614-1408738085=:7852--
