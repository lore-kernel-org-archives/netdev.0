From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: Re: Kernel panic nf_nat_setup_info+0x5b3/0x6e0
Date: Wed, 02 Mar 2011 22:50:25 +0300
Message-ID: <124481299095426@web67.yandex.ru>
References: <118081298480841@web25.yandex.ru> <4D6E2BEB.50805@trash.net> <AANLkTikkz23221ZSiat8N5tnE_bkHN=1EUNQTDdnC30L@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	Paul E McKenney <paulmck@linux.vnet.ibm.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikkz23221ZSiat8N5tnE_bkHN=1EUNQTDdnC30L@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

02.03.2011, 17:37, "Changli Gao" <xiaosuo@gmail.com>:

> t should be NULL here, as offsetof(struct nf_conn, dst.protonum) == 0x36.
> We should free the nf_ct_extend with call_rcu(), since nat ext is
> referenced in the rcu read context.

Yes, I think the problem is triggered when nf_conntrack_free() is called by
different CPU during net->ipv4.nat_bysource hash traversal. Extensions
framework doesn't have any SLAB_DESTROY_BY_RCU magic.

I'm not sure, but couldn't this problem be introduced by:

ea781f197d6a835cbb93a0bf88ee1696296ed8aa
netfilter: nf_conntrack: use SLAB_DESTROY_BY_RCU and get rid of call_rcu()

?

-- 
wbr, Oleg.
