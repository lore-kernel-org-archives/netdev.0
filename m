From: Stephen Hemminger <stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v4] Add TCP encap_rcv hook (repost)
Date: Sun, 22 Apr 2012 08:24:35 -0700 (PDT)
Message-ID: <64d4ef6b-f082-4c25-97c2-528773fb4566@tahiti.vyatta.com>
References: <20120419045333.GA21311@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20120419045333.GA21311-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
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



> This hook is based on a hook of the same name provided by UDP.  It
> provides
> a way for to receive packets that have a TCP header and treat them in
> some
> alternate way.
> 
> It is intended to be used by an implementation of the STT tunneling
> protocol within Open vSwtich's datapath. A prototype of such an
> implementation has been made.
> 
> The STT draft is available at
> http://tools.ietf.org/html/draft-davie-stt-01
> 
> My prototype STT implementation has been posted to the
> dev-UOEtcQmXneFl884UGnbwIQ@public.gmane.org
> The second version can be found at:
> http://www.mail-archive.com/dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org/msg09001.html
> It needs to be updated to call tcp_encap_enable()
> 
> Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
> 
>
> +static struct static_key tcp_encap_needed __read_mostly;
> +void tcp_encap_enable(void)
> +{
> +	if (!static_key_enabled(&tcp_encap_needed))
> +		static_key_slow_inc(&tcp_encap_needed);
> +}
> +EXPORT_SYMBOL(tcp_encap_enable);

I have reservations about adding such a hook. but if we
must, then the hook must be GPL only.
