From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH -next 0/6] Per network namespace netfilter chains
Date: Fri, 10 Jul 2015 18:11:46 -0500
Message-ID: <878uansj4d.fsf_-_@x220.int.ebiederm.org>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
	<87r3pae5hn.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 17 Jun 2015 10:09:40 -0500")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


By maintining a set of functions to register and unregister netfilter
hooks both globally and per network namespace I have managed to write a
compact patchset that maintain per network netfilter chains, and
registers the nftables netfilter hooks per network namespace.

There are lots of other possible and desirable cleanups but this one is
a core change needed to make the other changes independent small
changes.

Eric W. Biederman (6):
      netfilter: nf_queue: Don't recompute the hook_list head
      netfilter: kill nf_hooks_active
      netfilter: Simply the tests for enabling and disabling the ingress queue hook
      netfilter: Factor out the hook list selection from nf_register_hook
      netfilter: Per network namespace netfilter hooks.
      netfilter: nftables: Only run the nftables chains in the proper netns

 include/linux/netfilter.h      |  23 +++--
 include/net/netns/netfilter.h  |   1 +
 net/netfilter/core.c           | 221 +++++++++++++++++++++++++++++++++--------
 net/netfilter/nf_queue.c       |   2 +-
 net/netfilter/nf_tables_api.c  |   6 +-
 net/netfilter/nf_tables_core.c |   5 -
 6 files changed, 200 insertions(+), 58 deletions(-)

Eric
