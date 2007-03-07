From: Greg KH <gregkh@suse.de>
Subject: [patch 029/101] IPV6: HASHTABLES: Use appropriate seed for caluculating ehash index.
Date: Wed, 07 Mar 2007 09:11:04 -0800
Message-ID: <20070307171253.217963492@mini.kroah.org>
References: <20070307171035.150802805@mini.kroah.org>
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, handat@pm.nttdata.co.jp
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422785AbXCGRjb@vger.kernel.org>
Content-Disposition: inline; filename=ipv6-hashtables-use-appropriate-seed-for-caluculating-ehash-index.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Tetsuo Handa <handat@pm.nttdata.co.jp> told me that connect(2) with TCPv6
socket almost always took a few minutes to return when we did not have any
ports available in the range of net.ipv4.ip_local_port_range.

The reason was that we used incorrect seed for calculating index of
hash when we check established sockets in __inet6_check_established().

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/ipv6/inet6_hashtables.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.20.1.orig/net/ipv6/inet6_hashtables.c
+++ linux-2.6.20.1/net/ipv6/inet6_hashtables.c
@@ -172,7 +172,7 @@ static int __inet6_check_established(str
 	const struct in6_addr *saddr = &np->daddr;
 	const int dif = sk->sk_bound_dev_if;
 	const __portpair ports = INET_COMBINED_PORTS(inet->dport, lport);
-	const unsigned int hash = inet6_ehashfn(daddr, inet->num, saddr,
+	const unsigned int hash = inet6_ehashfn(daddr, lport, saddr,
 						inet->dport);
 	struct inet_ehash_bucket *head = inet_ehash_bucket(hinfo, hash);
 	struct sock *sk2;

--
