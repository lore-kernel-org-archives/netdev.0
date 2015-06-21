From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: inet_diag: export IPV6_V6ONLY sockopt
Date: Sun, 21 Jun 2015 01:52:57 -0700
Message-ID: <1434876777.31511.24.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150615205421.GA22616@orbit.nwl.cc>
	 <1434716132-25103-1-git-send-email-phil@nwl.cc>
	 <1434721920.31511.16.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150621014739.GA18664@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35240 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756AbbFUIxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 04:53:01 -0400
Received: by wiga1 with SMTP id a1so51758744wig.0
        for <netdev@vger.kernel.org>; Sun, 21 Jun 2015 01:53:00 -0700 (PDT)
In-Reply-To: <20150621014739.GA18664@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-06-21 at 03:47 +0200, Phil Sutter wrote:

> 
> > 1) This certainly should not compile on current linux trees.
> >    Always submit such patches on net-next.
> 
> It cleanly applies to net.git.

A very old one, because there is no ipv6only field anymore after
commit 9fe516ba3fb29b6f6a752ffd93342fdee500ec01 ("inet: move ipv6only in
sock_common") back in linux 3.17 

inet6_sk(sk)->ipv6only can not possibly compile today, I am pretty sure
of this.

# git grep -n ipv6only -- include
include/linux/ipv6.h:285:#define __ipv6_only_sock(sk)   (sk->sk_ipv6only)
include/linux/ipv6.h:297:static inline int inet_v6_ipv6only(const struct sock *sk)
include/linux/ipv6.h:299:       /* ipv6only field is at same position for timewait and other sockets */
include/linux/ipv6.h:324:#define tcp_twsk_ipv6only(__sk)                0
include/linux/ipv6.h:325:#define inet_v6_ipv6only(__sk)         0
include/net/inet_timewait_sock.h:58:#define tw_ipv6only         __tw_common.skc_ipv6only
include/net/sock.h:186: unsigned char           skc_ipv6only:1;
include/net/sock.h:325:#define sk_ipv6only              __sk_common.skc_ipv6only

So always make sure your tree is not one year old before submitting a patch.

Thanks.
