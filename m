From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] packet: tpacket_snd(): fix signed/unsigned comparison
Date: Tue, 28 Jul 2015 13:38:04 +0200
Message-ID: <1438083484.20182.43.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1438081021-1321-1-git-send-email-al.drozdov@gmail.com>
	 <55B76256.2040105@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Drozdov <al.drozdov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Eyal Birger <eyal.birger@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55B76256.2040105@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-07-28 at 13:07 +0200, Daniel Borkmann wrote:
> On 07/28/2015 12:57 PM, Alexander Drozdov wrote:
> > tpacket_fill_skb() can return a negative value (-errno) which
> > is stored in tp_len variable. In that case the following
> > condition will be (but shouldn't be) true:
> >
> > tp_len > dev->mtu + dev->hard_header_len
> >
> > as dev->mtu and dev->hard_header_len are both unsigned.
> >
> > That may lead to just returning an incorrect EMSGSIZE errno
> > to the user.
> >
> > Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>
> 
> Looks good to me, thanks!
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> --

Fixes: 52f1454f629fa ("packet: allow to transmit +4 byte in TX_RING slot for VLAN case")
