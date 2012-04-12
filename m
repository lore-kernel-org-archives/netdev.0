From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] udp: intoduce udp_encap_needed
	static_key
Date: Thu, 12 Apr 2012 11:10:11 +0200
Message-ID: <1334221811.5300.6021.camel@edumazet-glaptop>
References: <20120412074159.GA10866@verge.net.au>
	<1334218829.5300.5903.camel@edumazet-glaptop>
	<1334221528.5300.6008.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1334221528.5300.6008.camel@edumazet-glaptop>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-04-12 at 11:05 +0200, Eric Dumazet wrote:

> If static_key is not yet enabled, the fast path does a single JMP .
> 
> When static_key is enabled, JMP destination is patched to reach the real
> encap_type/encap_rcv logic, possibly adding cache misses.

Small note Simon,

The jump trick is effective on x86 (and maybe some other arches) when

CONFIG_JUMP_LABEL=y

Else, its replaced by atomic_read(...) > 0, a cnditional jump but
reading a read_mostly/shared variable, instead of a per socket field.
