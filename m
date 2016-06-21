From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [iproute PATCH v2 7/7] ip/tcp_metrics: Simplify process_msg a
 bit
Date: Tue, 21 Jun 2016 16:29:33 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4E17FB@AcuExch.aculab.com>
References: <1466525921-15738-1-git-send-email-phil@nwl.cc>
 <1466525921-15738-8-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Phil Sutter' <phil@nwl.cc>,
	Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.186]:63612 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337AbcFUQbk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 12:31:40 -0400
In-Reply-To: <1466525921-15738-8-git-send-email-phil@nwl.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Of Phil Sutter
> Sent: 21 June 2016 17:19
> By combining the attribute extraction and check for existence, the
> additional indentation level in the 'else' clause can be avoided.
> 
> In addition to that, common actions for 'daddr' are combined since the
> function returns if neither of the branches are taken.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  ip/tcp_metrics.c | 45 ++++++++++++++++++---------------------------
>  1 file changed, 18 insertions(+), 27 deletions(-)
> 
> diff --git a/ip/tcp_metrics.c b/ip/tcp_metrics.c
> index f82604f458ada..899830c127bcb 100644
> --- a/ip/tcp_metrics.c
> +++ b/ip/tcp_metrics.c
> @@ -112,47 +112,38 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
>  	parse_rtattr(attrs, TCP_METRICS_ATTR_MAX, (void *) ghdr + GENL_HDRLEN,
>  		     len);
> 
> -	a = attrs[TCP_METRICS_ATTR_ADDR_IPV4];
> -	if (a) {
> +	if ((a = attrs[TCP_METRICS_ATTR_ADDR_IPV4])) {

horrid
