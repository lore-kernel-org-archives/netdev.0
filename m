From: Jason Wang <jasowang@redhat.com>
Subject: macvlan crash in 3.9
Date: Tue, 21 May 2013 11:19:28 +0800
Message-ID: <519AE7C0.5090104@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, jwboyer@redhat.com
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53442 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751126Ab3EUDTh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 May 2013 23:19:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David:

We see macvlan crash in 3.9 because the precise packet length estimation
tries to use the transport header which hasn't been set. This has been
fixed in 3.10 and looks like at least the following commits needs to be
backported to 3.9 stable:

set transport header for untrusted packets:

9b4d669bc06c215d64f56f1eb0d4eb96e14d689d
38502af77e07b5d6650b9ff99a0b482d86366592
c1aad275b0293d2b1905ec95a945422262470684
f9ca8f74399f9195fd8e01f67a8424a8d33efa55
15e5a030716468dce4032fa0f398d840fa2756f6

and the commits that introduces skb_transport_header_was_set():

fda55eca5a33f33ffcd4192c6b2d75179714a52c

Thanks
