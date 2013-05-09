From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 07/21] netfilter: nf_nat: remove inline marking of EXPORT_SYMBOL functions
Date: Thu, 9 May 2013 10:47:33 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B722B@saturn3.aculab.com>
References: <1368086241-9357-1-git-send-email-yefremov.denis@gmail.com> <1368091192-10245-2-git-send-email-yefremov.denis@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Pablo Neira Ayuso" <pablo@netfilter.org>,
	"Patrick McHardy" <kaber@trash.net>, <netfilter@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<trivial@kernel.org>, <ldv-project@linuxtesting.org>
To: "Denis Efremov" <yefremov.denis@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1368091192-10245-2-git-send-email-yefremov.denis@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> EXPORT_SYMBOL and inline directives are contradictory to each other.
> The patch fixes this inconsistency.
...
> -inline const struct nf_nat_l4proto *
> +const struct nf_nat_l4proto *
>  __nf_nat_l4proto_find(u8 family, u8 protonum)
>  {
>  	return rcu_dereference(nf_nat_l4protos[family][protonum]);

If it makes sense to inline the local calls (ie the cost
of the call is significant) then possibly add an inlined
(or inlinable) static function that is called locally and
by the exported one?

I'm not sure that gcc is allowed to make the assumption
that the local exported function will be called - and
thus inline it.

	David
