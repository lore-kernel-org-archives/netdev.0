From: Paul Moore <paul@paul-moore.com>
Subject: Possible problem with e6afc8ac ("udp: remove headers from UDP packets
 before queueing")
Date: Wed, 1 Jun 2016 15:01:05 -0400
Message-ID: <CAHC9VhS0oH8p55_3yOcQGJWx8WmokHW=kSrKOM6tKPM1XoPjGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: samanthakumar@google.com
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I'm currently trying to debug a problem with 4.7-rc1 and labeled
networking over UDP.  I'm having some difficulty with the latest
4.7-rc1 builds on my test system at the moment so I haven't been able
to concisely identify the problem, but looking through the commits in
4.7-rc1 I think there may be a problem with the following:

  commit e6afc8ace6dd5cef5e812f26c72579da8806f5ac
  Author: samanthakumar <samanthakumar@google.com>
  Date:   Tue Apr 5 12:41:15 2016 -0400

   udp: remove headers from UDP packets before queueing

   Remove UDP transport headers before queueing packets for reception.
   This change simplifies a follow-up patch to add MSG_PEEK support.

   Signed-off-by: Sam Kumar <samanthakumar@google.com>
   Signed-off-by: Willem de Bruijn <willemb@google.com>
   Signed-off-by: David S. Miller <davem@davemloft.net>

... it appears that this commit changes things so that sk_filter() is
only called when sk->sk_filter is not NULL.  While this is fine for
the traditional socket filter case, it causes problems with LSMs that
make use of security_sock_rcv_skb() to enforce per-packet access
controls.

Hopefully I'll get 4.7-rc1 booting soon and I can do a proper
bisection test around this patch, but I wanted to mention this now in
case others are seeing the same problem.

-- 
paul moore
www.paul-moore.com
