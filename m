From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] netem: Fail cleanly if user input is wrong
Date: Fri, 20 Jan 2012 11:22:12 -0800
Message-ID: <20120120112212.30c50864@nehalam.linuxnetplumber.net>
References: <1327081825-6448-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36527 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754681Ab2ATTWO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jan 2012 14:22:14 -0500
In-Reply-To: <1327081825-6448-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Jan 2012 09:50:25 -0800
Vijay Subramanian <subramanian.vijay@gmail.com> wrote:

> (Resending patch since it looks like my earlier mail did not make it to
> netdev). 
> 
> netem reordering requires that the delay parameter be given. Currently, if no
> delay is given, tc prints the error message but still installs the qdisc. Fix
> this by printing the usage and failing cleanly.
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> ---
>  tc/q_netem.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/tc/q_netem.c b/tc/q_netem.c
> index b1fd452..23164d9 100644
> --- a/tc/q_netem.c
> +++ b/tc/q_netem.c
> @@ -395,6 +395,8 @@ static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
>  	if (reorder.probability) {
>  		if (opt.latency == 0) {
>  			fprintf(stderr, "reordering not possible without specifying some delay\n");
> +			explain();
> +			return -1;
>  		}
>  		if (opt.gap == 0)
>  			opt.gap = 1;

Applied
