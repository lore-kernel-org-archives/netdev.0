From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] flow_dissector: avoid uninitialized variable access
Date: Sat, 22 Oct 2016 00:16:29 +0200
Message-ID: <3516805.IZ705sLgKU@wuerfel>
References: <20161021155626.4020344-1-arnd@arndb.de> <20161021163118.GA2155@nanopsycho.orion> <5467015.N4DG5uA0DU@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexander Duyck <aduyck@mirantis.com>,
        Tom Herbert <tom@herbertland.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Gao Feng <fgao@ikuai8.com>, Eric Garver <e@erig.me>,
        Amir Vadai <amir@vadai.me>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5467015.N4DG5uA0DU@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, October 21, 2016 11:05:45 PM CEST Arnd Bergmann wrote:
> 
> Can you explain why "dissector_uses_key(flow_dissector,
> FLOW_DISSECTOR_KEY_VLAN) && skb_vlan_tag_present(skb)" implies
> "eth_type_vlan(proto))"?
> 
> If I add uninitialized_var() here, I would at least put that in
> a comment here.

Found it now myself: if skb_vlan_tag_present(skb), then we don't
access 'vlan', otherwise we know it is initialized because
eth_type_vlan(proto) has to be true.
 
> On a related note, I also don't see how
> "dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_VLAN)"
> implies that skb is non-NULL. I guess this is related to the
> first one.

I'm still unsure about this one.

I also found something else that is suspicious: 'vlan' points
to the local _vlan variable, but that has gone out of scope
by the time we access the pointer, which doesn't seem safe.

	Arnd
