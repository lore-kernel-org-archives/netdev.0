From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4: optimize xmit path
Date: Sun, 28 Sep 2014 11:52:44 -0700
Message-ID: <1411930364.15768.80.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAMEtUuxwQ8k1wcT8U0VncnVoN=vZjU3zxswgjYPcQTLPw2pRwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:49633 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbaI1Swp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 14:52:45 -0400
Received: by mail-pd0-f182.google.com with SMTP id y10so4092924pdj.27
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 11:52:45 -0700 (PDT)
In-Reply-To: <CAMEtUuxwQ8k1wcT8U0VncnVoN=vZjU3zxswgjYPcQTLPw2pRwA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-09-28 at 11:07 -0700, Alexei Starovoitov wrote:

> this is great improvement!
> Thank you for leading this effort.
> 10G line rate is definitely nice :)
> Hopefully Or can demo similar numbers with 40G nic as well :)
> 
> > +       if (ring->bf_enabled && desc_size <= MAX_BF && !bounce &&
> > +           !vlan_tx_tag_present(skb) && send_doorbell) {
> 
> feels something wrong here, since it checks for
> send_doorbell, but iowrite() happens in the 'else' part
> of this branch with another 'if (send_doorbell)'
> 

If we do not plan to send a doorbell, we should not use blueframe.

Blueframe is always sending a doorbell by design, as it uses a single
flip buffer.

So if you want to see any improvement thanks to skb->xmit_more, we have
to use the iowrite32(), not the blueframe.

Therefore , if send_doorbell == false, we do not want the doorbell

Is it making sense now ? ;)
