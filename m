From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 5/9] net: network drivers no longer need to
 implement ndo_busy_poll()
Date: Tue, 17 Nov 2015 08:03:24 -0800
Message-ID: <1447776204.22599.114.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447768624-14962-1-git-send-email-edumazet@google.com>
	 <1447768624-14962-6-git-send-email-edumazet@google.com>
	 <564B4443.90108@linux.intel.com>
	 <1447774421.22599.109.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Eli Cohen <eli@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>,
	Rida Assaf <rida@google.com>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36702 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287AbbKQQDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 11:03:32 -0500
Received: by pacdm15 with SMTP id dm15so12688382pac.3
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 08:03:32 -0800 (PST)
In-Reply-To: <1447774421.22599.109.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-17 at 07:33 -0800, Eric Dumazet wrote:

> This is exactly what I suggested in the changelog ;)

In v2 I am adding a patch to move skb_mark_napi_id() out of drivers into
net core stack (napi_gro_receive() & napi_gro_frags())

But adding the rcu stuff in napi_napi_del() wont be a trivial patch.

Also, mlx4 uses a NAPI for TX completions only, I suspect other drivers
might do the same, so we would fill napi_hash[] with napi contexts that
would not be used in RX at all.
