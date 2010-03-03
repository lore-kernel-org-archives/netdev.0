From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH 1/8] net: add limit for socket backlog
Date: Wed, 03 Mar 2010 15:35:28 +0800
Message-ID: <1267601728.2370.47.camel@debian>
References: <1267598111-12503-1-git-send-email-yi.zhu@intel.com>
	 <1267599269.2839.84.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Per Liden <per.liden@ericsson.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	Andrew Hendry <andrew.hendry@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41201 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752058Ab0CCHdp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 02:33:45 -0500
In-Reply-To: <1267599269.2839.84.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-03-03 at 14:54 +0800, Eric Dumazet wrote:
> > diff --git a/include/net/sock.h b/include/net/sock.h
> > index 6cb1676..847119a 100644
> > --- a/include/net/sock.h
> > +++ b/include/net/sock.h
> > @@ -253,6 +253,8 @@ struct sock {
> >  	struct {
> >  		struct sk_buff *head;
> >  		struct sk_buff *tail;
> > +		int len;
> > +		int limit;
> 
> This new limit field is really not needed

sk->sk_rcvbuf can be adjusted by setsockopt from user at run time. The
minimum allowed value is 256. I'm afraid this will break most protocols.

<...>

> Ouch, this patch breaks bisection, since all protocols currently ignore
> -ENOBUFS value and dont free skb
> 
> If you split your work on several patches, you still have to make
> resulting kernels usable.

OK. Will fix.

<...>

> > +	sk->sk_backlog.limit	=	sk->sk_rcvbuf >> 1;

Sorry, typo.

Thanks,
-yi

