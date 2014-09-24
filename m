From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 1/1 V4] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Wed, 24 Sep 2014 12:22:30 -0700
Message-ID: <1411586550.15395.46.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140924160932.9721.56450.stgit@localhost>
	 <20140924161047.9721.43080.stgit@localhost>
	 <1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140924195831.6fb91051@redhat.com>
	 <CA+mtBx8s63TDe1XS7TzfscwhiRCgyeLkKLz2p-4et1erX0-dUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Toke =?ISO-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>,
	Florian Westphal <fw@strlen.de>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Dave Taht <dave.taht@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:54935 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076AbaIXTWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 15:22:25 -0400
Received: by mail-pa0-f46.google.com with SMTP id kx10so9281599pab.19
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 12:22:25 -0700 (PDT)
In-Reply-To: <CA+mtBx8s63TDe1XS7TzfscwhiRCgyeLkKLz2p-4et1erX0-dUQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-24 at 11:34 -0700, Tom Herbert wrote:
> >
> I believe drivers typically use skb->len for BQL tracking. Since
> bytelimit is based on BQL here, it might be more correct to use
> skb->len.

That is only because drivers dont have access to qdisc_pkt_len(skb) as :

- We can call them without any qdisc traversal
- We escaped from qdisc layer, and gso packet do not have the field set

And drivers actually update BQL inflight, while bulk dequeue do not
update it (its a local copy)

I do not particularly care, as BQL do not have to be 100% precise.
