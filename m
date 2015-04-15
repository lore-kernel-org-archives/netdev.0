From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Xen-devel] "tcp: refine TSO autosizing" causes performance
 regression on Xen
Date: Wed, 15 Apr 2015 10:52:53 -0700
Message-ID: <1429120373.7346.125.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1504091344260.7690@kaball.uk.xensource.com>
	 <1428596218.25985.263.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1504091729160.7690@kaball.uk.xensource.com>
	 <CAFLBxZaVjFHh4UBnksGZS4waBr4jLdO8aJegyKvsU1-TvVt2Dg@mail.gmail.com>
	 <1428932970.3834.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAFLBxZYt7-v29ysm=f+5QMOw64_QhESjzj98udba+1cS-PfObA@mail.gmail.com>
	 <1429115934.7346.107.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552E9E8D.1080000@eu.citrix.com>
	 <1429118948.7346.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552EA2BC.5000707@eu.citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jonathan Davies <Jonathan.Davies@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Paul Durrant <paul.durrant@citrix.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	Felipe Franciosi <felipe.franciosi@citrix.com>,
	linux-arm-kernel@lists.infradead.org,
	David Vrabel <david.vrabel@citrix.com>
To: George Dunlap <george.dunlap@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:32893 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753395AbbDORwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 13:52:55 -0400
In-Reply-To: <552EA2BC.5000707@eu.citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-15 at 18:41 +0100, George Dunlap wrote:

> So you'd be OK with a patch like this?  (With perhaps a better changelog?)
> 
>  -George
> 
> ---
> TSQ: Raise default static TSQ limit
> 
> A new dynamic TSQ limit was introduced in c/s 605ad7f18 based on the
> size of actual packets and the amount of data being transmitted.
> Raise the default static limit to allow that new limit to actually
> come into effect.
> 
> This fixes a regression where NICs with large transmit completion
> times (such as xennet) had a 30% hit unless the user manually tweaked
> the value in /proc.
> 
> Signed-off-by: George Dunlap <george.dunlap@eu.citrix.com>
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 1db253e..8ad7cdf 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -50,8 +50,8 @@ int sysctl_tcp_retrans_collapse __read_mostly = 1;
>   */
>  int sysctl_tcp_workaround_signed_windows __read_mostly = 0;
> 
> -/* Default TSQ limit of two TSO segments */
> -int sysctl_tcp_limit_output_bytes __read_mostly = 131072;
> +/* Static TSQ limit.  A more dynamic limit is calculated in
> tcp_write_xmit. */
> +int sysctl_tcp_limit_output_bytes __read_mostly = 1048576;
> 
>  /* This limits the percentage of the congestion window which we
>   * will allow a single TSO frame to consume.  Building TSO frames
> 

Have you tested this patch on a NIC without GSO/TSO ?

This would allow more than 500 packets for a single flow.

Hello bufferbloat.

So my answer to this patch is a no.
