From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/4] net-next: dsa: fix flow dissection
Date: Wed, 09 Aug 2017 23:42:15 -0700
Message-ID: <1502347335.4936.2.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170809124119.24320-1-john@phrozen.org>
         <20170809.225243.2204411285392662424.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        sean.wang@mediatek.com, netdev@vger.kernel.org,
        linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
        muciri@openmesh.com, shashidhar.lakkavalli@openmesh.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170809.225243.2204411285392662424.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-08-09 at 22:52 -0700, David Miller wrote:
> From: John Crispin <john@phrozen.org>
> Date: Wed,  9 Aug 2017 14:41:15 +0200
> 
> > RPS and probably other kernel features are currently broken on some if not
> > all DSA devices. The root cause of this is that skb_hash will call the
> > flow_dissector. At this point the skb still contains the magic switch
> > header and the skb->protocol field is not set up to the correct 802.3
> > value yet. By the time the tag specific code is called, removing the header
> > and properly setting the protocol an invalid hash is already set. In the
> > case of the mt7530 this will result in all flows always having the same
> > hash.
> > 
> > Changes since RFC:
> > * use a callback instead of static values
> > * add cover letter
> 
> Series applied, thanks.

Is this related ?

net/core/flow_dissector.c: In function '__skb_flow_dissect':
net/core/flow_dissector.c:448:18: error: 'struct net_device' has no member named 'dsa_ptr'
    ops = skb->dev->dsa_ptr->tag_ops;
                  ^
make[3]: *** [net/core/flow_dissector.o] Error 1
