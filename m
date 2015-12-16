From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v7 0/4] Support administratively closing application
 sockets
Date: Wed, 16 Dec 2015 07:50:13 -0800
Message-ID: <1450281013.8474.73.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1450236605-87170-1-git-send-email-lorenzo@google.com>
	 <20151216074334.593a1ad6@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org,
	davem@davemloft.net, hannes@stressinduktion.org, ek@google.com,
	tom@herbertland.com, zenczykowski@gmail.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35692 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965752AbbLPPuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 10:50:16 -0500
Received: by mail-pa0-f48.google.com with SMTP id tl7so3158859pab.2
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 07:50:15 -0800 (PST)
In-Reply-To: <20151216074334.593a1ad6@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-12-16 at 07:43 -0800, Stephen Hemminger wrote:

> 
> I see no security checks in the diag infrastructure.
> Up until now diag has been read-only access and therefore has been
> allowed for all users.

It is still allowed to all users.

Only the 'destroy' operation is restricted.


+int sock_diag_destroy(struct sock *sk, int err)
+{
+       if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
+               return -EPERM;
+
+       if (!sk->sk_prot->diag_destroy)
+               return -EOPNOTSUPP;
+
+       return sk->sk_prot->diag_destroy(sk, err);
+}
+EXPORT_SYMBOL_GPL(sock_diag_destroy);
