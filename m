From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: fix oops in backup for fwmark conn templates
Date: Mon, 28 Apr 2008 11:58:55 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0804281151550.3315@u.domain.uli>
References: <Pine.LNX.4.58.0804281028110.2775@u.domain.uli>
 <20080428083011.GA6139@verge.net.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>,
	"Rumen G. Bogdanovski" <rumen@voicecho.com>,
	Wensong Zhang <wensong@linux-vs.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:55949 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1765436AbYD1I6U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 04:58:20 -0400
In-Reply-To: <20080428083011.GA6139@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 28 Apr 2008, Simon Horman wrote:

> On Mon, Apr 28, 2008 at 10:52:38AM +0300, Julian Anastasov wrote:
> > 
> > 	Fixes bug http://bugzilla.kernel.org/show_bug.cgi?id=10556
> > where conn templates with protocol=IPPROTO_IP can oops backup box.
> > 
> >         Result from ip_vs_proto_get() should be checked because
> > protocol value can be invalid or unsupported in backup. But
> > for valid message we should not fail for templates which use
> > IPPROTO_IP. Also, add checks to validate message limits and
> > connection state. Show state NONE for templates using IPPROTO_IP.
> 
> Julian, am I right in thinking that this is a long-standing bug
> rather than a recent regression?

	Bug reporter is using 2.6.24.4, bug comes with 2.6.24,
pp is NULL for IPPROTO_IP, 2.6.24 shows:

[IPVS]: use proper timeout instead of fixed value

-               cp->timeout = IP_VS_SYNC_CONN_TIMEOUT;
+               cp->state = ntohs(s->state);
+               pp = ip_vs_proto_get(s->protocol);
+               cp->timeout = pp->timeout_table[cp->state];

Regards

--
Julian Anastasov <ja@ssi.bg>
