From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] flow_dissector: avoid uninitialized variable access
Date: Fri, 21 Oct 2016 23:05:45 +0200
Message-ID: <5467015.N4DG5uA0DU@wuerfel>
References: <20161021155626.4020344-1-arnd@arndb.de> <20161021163118.GA2155@nanopsycho.orion>
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
In-Reply-To: <20161021163118.GA2155@nanopsycho.orion>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, October 21, 2016 6:31:18 PM CEST Jiri Pirko wrote:
> Fri, Oct 21, 2016 at 05:55:53PM CEST, arnd@arndb.de wrote:
> >gcc warns about an uninitialized pointer dereference in the vlan
> >priority handling:
> >
> >net/core/flow_dissector.c: In function '__skb_flow_dissect':
> >net/core/flow_dissector.c:281:61: error: 'vlan' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> >
> >From all I can tell, this warning is about a real bug, and we
> >should not attempt look up the vlan header if there was
> >no vlan tag.
> 
> I don't see how vlan could be used uninitialized. But I understand that
> this is impossible for gcc to track it. Please just use uninitialized_var()
> 

I usually try to avoid uninitialized_var(), as making it obvious to
the compiler why something is known tends to result in more readable
source code and better object code.

Can you explain why "dissector_uses_key(flow_dissector,
FLOW_DISSECTOR_KEY_VLAN) && skb_vlan_tag_present(skb)" implies
"eth_type_vlan(proto))"?

If I add uninitialized_var() here, I would at least put that in
a comment here.

On a related note, I also don't see how
"dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_VLAN)"
implies that skb is non-NULL. I guess this is related to the
first one.

	Arnd
