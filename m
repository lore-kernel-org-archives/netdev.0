From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [IPROUTE 01/05]: Use tc_calc_xmittime where appropriate
Date: Tue, 16 Jan 2007 09:56:11 +0100
Message-ID: <20070116085611.GA1003@ff.dom.local>
References: <20070110100144.29356.52367.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:45244 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932461AbXAPIyE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jan 2007 03:54:04 -0500
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <20070110100144.29356.52367.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10-01-2007 11:01, Patrick McHardy wrote:
> [IPROUTE]: Use tc_calc_xmittime where appropriate
> 
> Replace expressions of the form "1000000 * size/rate" by tc_calc_xmittime().
> The CBQ case deserves an extra comment: when called with bnwd=rate
> tc_cbq_calc_maxidle behaves identical to tc_calc_xmittime, so use it
> for clarity.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> ---
...
> diff --git a/tc/tc_red.c b/tc/tc_red.c
> index 385e7af..8f9bde0 100644
> --- a/tc/tc_red.c
> +++ b/tc/tc_red.c
> @@ -71,7 +71,7 @@ int tc_red_eval_ewma(unsigned qmin, unsi
>  
>  int tc_red_eval_idle_damping(int Wlog, unsigned avpkt, unsigned bps, __u8 *sbuf)
>  {
> -	double xmit_time = tc_core_usec2tick(1000000*(double)avpkt/bps);
> +	double xmit_time = tc_calc_xmittime(bps, avpkt);

Return value changed to unsigned here.
(According to iproute2-2.6.19-061214.) 

>  	double lW = -log(1.0 - 1.0/(1<<Wlog))/xmit_time;
>  	double maxtime = 31/lW;
>  	int clog;
