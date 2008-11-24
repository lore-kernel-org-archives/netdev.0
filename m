From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] netfilter: nf_conntrack_sctp: fix build warning
Date: Mon, 24 Nov 2008 20:50:30 +0800
Message-ID: <20081124125030.GA14047@localhost>
References: <20081123113315.GA16697@localhost> <20081123.135955.202482968.davem@davemloft.net> <20081124000652.GA5424@localhost> <4929FEA9.9090801@cn.fujitsu.com> <20081124011727.GA6462@localhost> <492A9CB4.3060004@trash.net> <20081124123516.GB12944@localhost> <492AA287.6020002@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wang Chen <wangchen@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:26475 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751288AbYKXMuy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2008 07:50:54 -0500
Content-Disposition: inline
In-Reply-To: <492AA287.6020002@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2008 at 02:48:07PM +0200, Patrick McHardy wrote:
> Wu Fengguang wrote:
> > On Mon, Nov 24, 2008 at 02:23:16PM +0200, Patrick McHardy wrote:
> >> +	/* Avoid bogus warning, gcc doesn't realize do_basic_checks()
> >> +	 * guarantees that there is at least one SCTP chunk.
> >> +	 */
> >> +	if (unlikely(new_state == SCTP_CONNTRACK_MAX))
> >> +		goto out;
> >> +
> > 
> > If do_basic_checks() guarantees that, why not Initialize new_state to 0?
> 
> Good point. I've replaced the patch by this one:

Thanks!

Fengguang

Content-Description: x
> commit 328bd8997dbb7184d5389e45c642af44ae6e9043
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Mon Nov 24 13:44:55 2008 +0100
> 
>     netfilter: nf_conntrack_proto_sctp: avoid bogus warning
>     
>     net/netfilter/nf_conntrack_proto_sctp.c: In function 'sctp_packet':
>     net/netfilter/nf_conntrack_proto_sctp.c:376: warning: array subscript is above array bounds
>     
>     gcc doesn't realize that do_basic_checks() guarantees that there is
>     at least one valid chunk and thus new_state is never SCTP_CONNTRACK_MAX
>     after the loop. Initialize to SCTP_CONNTRACK_NONE to avoid the warning.
>     
>     Based on patch by Wu Fengguang <wfg@linux.intel.com>
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
> index c2bd457..74e0379 100644
> --- a/net/netfilter/nf_conntrack_proto_sctp.c
> +++ b/net/netfilter/nf_conntrack_proto_sctp.c
> @@ -317,7 +317,7 @@ static int sctp_packet(struct nf_conn *ct,
>  		goto out;
>  	}
>  
> -	old_state = new_state = SCTP_CONNTRACK_MAX;
> +	old_state = new_state = SCTP_CONNTRACK_NONE;
>  	write_lock_bh(&sctp_lock);
>  	for_each_sctp_chunk (skb, sch, _sch, offset, dataoff, count) {
>  		/* Special cases of Verification tag check (Sec 8.5.1) */

