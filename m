From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] ipv6: do not hold route table lock when send ndisc
 probe
Date: Thu, 23 Aug 2012 18:10:32 +0200
Message-ID: <1345738232.5904.1244.camel@edumazet-glaptop>
References: <1345187499-16929-1-git-send-email-amwang@redhat.com>
	 <CAATkVEzKuTeUbU75B6EoSfFvGVsz_eK47XNWmsP5KcCvjTDEDA@mail.gmail.com>
	 <1345520643.12468.6.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Debabrata Banerjee <dbavatar@gmail.com>, netdev@vger.kernel.org,
	"Banerjee, Debabrata" <dbanerje@akamai.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39234 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754037Ab2HWQKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 12:10:38 -0400
Received: by bkwj10 with SMTP id j10so307393bkw.19
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 09:10:36 -0700 (PDT)
In-Reply-To: <1345520643.12468.6.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-21 at 11:44 +0800, Cong Wang wrote:
> Hi, Debabrata,
> 
> Could you help to test the attached patch below?
> 
> Thanks!
> 

Hard to comment on your patch since its not inlined.

+               nw = kmalloc(sizeof(*nw), GFP_ATOMIC);
+               if (nw) {
+                       memcpy(&nw->target, &neigh->primary_key, sizeof(struct in6_addr));
+                       addrconf_addr_solict_mult(&nw->target, &nw->mcaddr);
+                       nw->dev = rt->dst.dev;
+                       INIT_WORK(&nw->work, queue_ndisc);
+                       schedule_work(&nw->work);
+               }

You cant do that without taking extra reference on dev,
and release it in queue_ndisc()

This also will add interesting side effects at device dismantle.
