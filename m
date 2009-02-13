From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Fri, 13 Feb 2009 16:03:47 +0300
Message-ID: <20090213130347.GD23879@ioremap.net>
References: <20090212171245.GA15025@ioremap.net> <alpine.LSU.2.00.0902121900520.20367@fbirervta.pbzchgretzou.qr> <20090212185729.GA17896@ioremap.net> <alpine.LSU.2.00.0902122045080.670@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intermatrixgroup.ru ([195.178.208.66]:43522 "EHLO
	tservice.net.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455AbZBMNDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 08:03:49 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.0902122045080.670@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 12, 2009 at 09:12:05PM +0100, Jan Engelhardt (jengelh@medozas.de) wrote:
> >> >+config IP_NF_MATCH_OSF
> >> >+	tristate '"osf" match support'
> >> >+	depends on NETFILTER_ADVANCED && CONNECTOR
> >> >+	help
> >> >+	  Passive OS fingerprint matching module.
> >> >+	  You should download and install rule loading software from
> >> >+	  http://www.ioremap.net/projects/osf
> >> >+
> >> >+	  To compile it as a module, choose M here.  If unsure, say N.
> >> >+
> >> 
> >> Please do use NETFILTER_XT_ and its section.
> >
> >What's this? It does not exist in the net/ipv4/netfilter/Kconfig
> 
> net/netfilter/Kconfig: (e.g.)
> 
> config NETFILTER_XT_MATCH_COMMENT
>         tristate  '"comment" match support'
>         depends on NETFILTER_ADVANCED
>         ---help---

But I placed OSF into net/ipv4/netfilter/ipt_osf.c, should it be moved
into different location?

> >> >+			for (optnum = 0; optnum < f->opt_num; ++optnum) {
> >> >+				if (f->opt[optnum].kind == (*optp)) {
> >> >+					__u32 len = f->opt[optnum].length;
> >> >+					__u8 *optend = optp + len;
> >> >+					int loop_cont = 0;
> >> >+					
> >> >+					fmatch = FMATCH_OK;
> >> >+
> >> >+					switch (*optp) {
> >> >+					case OSFOPT_MSS:
> >> >+						mss = ntohs(*(u16 *)(optp + 2));
> >> 
> >> This needs get_unaligned(), in case someone sends a malicious packet.
> >
> >Hmmm, why is this needed? We dereference linear kernel pointer at
> >proper offset (modulo of the option size).
> 
> What if optp is odd?

It cant, header is fixed and every option length is also fixed (and its
size is checked).

-- 
	Evgeniy Polyakov
