From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Sun, 7 Jun 2009 19:12:18 +0400
Message-ID: <20090607151218.GA31757@ioremap.net>
References: <20090604162212.GA24661@ioremap.net> <4A290767.6080202@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from broadrack.ru ([195.178.208.66]:34559 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754316AbZFGPMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Jun 2009 11:12:25 -0400
Content-Disposition: inline
In-Reply-To: <4A290767.6080202@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick.

I've added mentioned cleanups except the one described below.

On Fri, Jun 05, 2009 at 01:54:15PM +0200, Patrick McHardy (kaber@trash.net) wrote:

> >+	tcp = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(struct tcphdr), 
> >&_tcph);
> >+	if (!tcp)
> >+		return false;
> >+
> >+	if (!tcp->syn)
> >+		return false;
> >+
> >+	totlen = ntohs(ip->tot_len);
> >+	df = ntohs(ip->frag_off) & IP_DF;
> >+	window = ntohs(tcp->window);
> >+
> >+	if (tcp->doff * 4 > sizeof(struct tcphdr)) {
> >+		optsize = tcp->doff * 4 - sizeof(struct tcphdr);
> 
> tcp_optlen()?

TCP header is potentially copied above and transport header may be not
set, so I work with that part of skb without assuming it was previously
set by lower layers.

> >+		if (info->flags & XT_OSF_LOG) {
> >+			if (info->loglevel != XT_OSF_LOGLEVEL_ALL_KNOWN)
> >+				nf_log_packet(p->hooknum, 0, skb, p->in, 
> >p->out, NULL,
> >+					"window: %u, mss: %u, totlen: %u, 
> >df: %d, ttl: %u : ",
> >+					window, mss, totlen, df, ip->ttl);
> 
> nf_log_packet() can pass the entire packet to userspace. Header-field
> extraction should be done by whatever is logging in userspace. This
> looks very much like debugging anyways, where is the actual message?

Message itself is 'printed' couple of lines below, but apparently it is
not needed for nf_log_packet, only for the printk()-based debug, so I
dropped that part.

-- 
	Evgeniy Polyakov
