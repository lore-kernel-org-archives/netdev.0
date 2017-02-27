From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH 2/2] iproute2: add support for invisible qdisc dumping
Date: Mon, 27 Feb 2017 12:52:18 +0100
Message-ID: <20170227115218.GO6099@orbyte.nwl.cc>
References: <alpine.LSU.2.20.1702252228010.24579@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jiri Kosina <jikos@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35627 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751550AbdB0MBW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Feb 2017 07:01:22 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.20.1702252228010.24579@cbobk.fhfr.pm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 25, 2017 at 10:29:17PM +0100, Jiri Kosina wrote:
> From: Jiri Kosina <jkosina@suse.cz>
> 
> Support the new TCA_DUMP_INVISIBLE netlink attribute that allows asking 
> kernel to perform 'full qdisc dump', as for historical reasons some of the 
> default qdiscs are being hidden by the kernel.
> 
> The command syntax is being extended by voluntary 'invisible' argument to
> 'tc qdisc show'.
> 
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> ---
>  tc/tc_qdisc.c | 25 +++++++++++++++++++++++--
>  1 file changed, 23 insertions(+), 2 deletions(-)

Would you mind adding a description of the new keyword to tc man page as
well?

> diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
> index 3a3701c2..29da9269 100644
> --- a/tc/tc_qdisc.c
> +++ b/tc/tc_qdisc.c
> @@ -34,7 +34,7 @@ static int usage(void)
>  	fprintf(stderr, "       [ stab [ help | STAB_OPTIONS] ]\n");
>  	fprintf(stderr, "       [ [ QDISC_KIND ] [ help | OPTIONS ] ]\n");
>  	fprintf(stderr, "\n");
> -	fprintf(stderr, "       tc qdisc show [ dev STRING ] [ ingress | clsact ]\n");
> +	fprintf(stderr, "       tc qdisc show [ dev STRING ] [ ingress | clsact | invisible ]\n");

Doesn't look like these are mutually exclusive. Therefore I would
suggest fixing the syntax to:

| +	fprintf(stderr, "       tc qdisc show [ dev STRING ] [ ingress | clsact ] [ invisible ]\n");

Cheers, Phil
