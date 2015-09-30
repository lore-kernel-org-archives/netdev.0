From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next:master 414/428] net/ipv6/tcp_ipv6.c:930: warning:
 passing argument 1 of 'tcp_v6_md5_do_lookup' discards qualifiers from
 pointer target type
Date: Tue, 29 Sep 2015 21:10:28 -0700
Message-ID: <1443586228.32531.12.camel@edumazet-glaptop2.roam.corp.google.com>
References: <201509301242.V51qs4FL%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, kbuild-all@01.org,
	netdev@vger.kernel.org
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35024 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345AbbI3EKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 00:10:30 -0400
Received: by pacfv12 with SMTP id fv12so27209866pac.2
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 21:10:30 -0700 (PDT)
In-Reply-To: <201509301242.V51qs4FL%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-09-30 at 12:01 +0800, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   e6934f3ec00b04234acb24a1a2c28af59763d3b5
> commit: a00e74442bac5ad19a929d097370da7e07540ea6 [414/428] tcp/dccp: constify send_synack and send_reset socket argument
> config: avr32-atngw100_defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout a00e74442bac5ad19a929d097370da7e07540ea6
>   # save the attached .config to linux build tree
>   make.cross ARCH=avr32 
> 
> All warnings (new ones prefixed by >>):
> 
>    net/ipv6/tcp_ipv6.c: In function 'tcp_v6_reqsk_send_ack':
> >> net/ipv6/tcp_ipv6.c:930: warning: passing argument 1 of 'tcp_v6_md5_do_lookup' discards qualifiers from pointer target type
>    net/ipv6/tcp_ipv6.c:926: warning: passing argument 1 of 'tcp_v6_md5_do_lookup' discards qualifiers from pointer target type
> 
> vim +/tcp_v6_md5_do_lookup +930 net/ipv6/tcp_ipv6.c
> 
> 9c76a114b Wang Yufen               2014-03-29  914  			tcptw->tw_ts_recent, tw->tw_bound_dev_if, tcp_twsk_md5_key(tcptw),
> 21858cd02 Florent Fourcot          2015-05-16  915  			tw->tw_tclass, cpu_to_be32(tw->tw_flowlabel));
> ^1da177e4 Linus Torvalds           2005-04-16  916  
> 8feaf0c0a Arnaldo Carvalho de Melo 2005-08-09  917  	inet_twsk_put(tw);
> ^1da177e4 Linus Torvalds           2005-04-16  918  }
> ^1da177e4 Linus Torvalds           2005-04-16  919  
> a00e74442 Eric Dumazet             2015-09-29  920  static void tcp_v6_reqsk_send_ack(const struct sock *sk, struct sk_buff *skb,
> 6edafaaf6 Gui Jianfeng             2008-08-06  921  				  struct request_sock *req)
> ^1da177e4 Linus Torvalds           2005-04-16  922  {
> 3a19ce0ee Daniel Lee               2014-05-11  923  	/* sk->sk_state == TCP_LISTEN -> for regular TCP_SYN_RECV
> 3a19ce0ee Daniel Lee               2014-05-11  924  	 * sk->sk_state == TCP_SYN_RECV -> for Fast Open.
> 3a19ce0ee Daniel Lee               2014-05-11  925  	 */
> 0f85feae6 Eric Dumazet             2014-12-09  926  	tcp_v6_send_ack(sk, skb, (sk->sk_state == TCP_LISTEN) ?
> 3a19ce0ee Daniel Lee               2014-05-11  927  			tcp_rsk(req)->snt_isn + 1 : tcp_sk(sk)->snd_nxt,
> 0f85feae6 Eric Dumazet             2014-12-09  928  			tcp_rsk(req)->rcv_nxt, req->rcv_wnd,
> 0f85feae6 Eric Dumazet             2014-12-09  929  			tcp_time_stamp, req->ts_recent, sk->sk_bound_dev_if,
> 1d13a96c7 Florent Fourcot          2014-01-16 @930  			tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr),
> 1d13a96c7 Florent Fourcot          2014-01-16  931  			0, 0);
> ^1da177e4 Linus Torvalds           2005-04-16  932  }
> ^1da177e4 Linus Torvalds           2005-04-16  933  
> ^1da177e4 Linus Torvalds           2005-04-16  934  
> ^1da177e4 Linus Torvalds           2005-04-16  935  static struct sock *tcp_v6_hnd_req(struct sock *sk, struct sk_buff *skb)
> ^1da177e4 Linus Torvalds           2005-04-16  936  {
> aa8223c7b Arnaldo Carvalho de Melo 2007-04-10  937  	const struct tcphdr *th = tcp_hdr(skb);
> 52452c542 Eric Dumazet             2015-03-19  938  	struct request_sock *req;
> 
> :::::: The code at line 930 was first introduced by commit
> :::::: 1d13a96c74fc4802a775189ddb58bc6469ffdaa3 ipv6: tcp: fix flowlabel value in ACK messages send from TIME_WAIT
> 
> :::::: TO: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
> :::::: CC: David S. Miller <davem@davemloft.net>
> 
> ---

Thanks, probably a matter of applying this patch.

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 0ac64f47f8821ce7da103ecc7391ba7e..2ae95e1d03e1c0d5149c9f6fa7cf94d9 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -82,7 +82,7 @@ static const struct inet_connection_sock_af_ops ipv6_specific;
 static const struct tcp_sock_af_ops tcp_sock_ipv6_specific;
 static const struct tcp_sock_af_ops tcp_sock_ipv6_mapped_specific;
 #else
-static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
+static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(const struct sock *sk,
 						   const struct in6_addr *addr)
 {
 	return NULL;
