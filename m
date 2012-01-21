From: MuraliRaja Muniraju <muralira@google.com>
Subject: Query regarding a code snippet in __inet_lookup_established.
Date: Fri, 20 Jan 2012 17:02:36 -0800
Message-ID: <CAP3iWTRS5d5dHLFpkOmiTuh46pPnFLLiJ1FG=WTumt-1B8DgZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:49102 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674Ab2AUBCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 20:02:36 -0500
Received: by iacb35 with SMTP id b35so345262iac.19
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2012 17:02:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,
    In function __inet_lookup_established, I do see a potential issue
in a corner case while reading through the code where socket can be
freed while being in the list and also while in rcu_read critical
section.
        rcu_read_lock();
begin:
        sk_nulls_for_each_rcu(sk, node, &head->chain) {
                if (INET_MATCH(sk, net, hash, acookie,
                                        saddr, daddr, ports, dif)) {
                        if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt)))
                                goto begintw;
                        if (unlikely(!INET_MATCH(sk, net, hash, acookie,
                                saddr, daddr, ports, dif))) {
Murali>                                sock_put(sk);
Murali>                                goto begin;
                        }
                        goto out;
                }
        }

I am not certain under what scenario this might occur. Can someone let
me know if this is a possibility.
-- 
Thanks,
Murali
