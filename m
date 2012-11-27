From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: move inet_dport/inet_num in sock_common
Date: Tue, 27 Nov 2012 13:23:21 -0800
Message-ID: <1354051401.14302.40.camel@edumazet-glaptop>
References: <1354028815.14302.35.camel@edumazet-glaptop>
	 <1354043156.2701.17.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ling Ma <ling.ma.program@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:50344 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217Ab2K0VXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 16:23:24 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so9188044pbc.19
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 13:23:24 -0800 (PST)
In-Reply-To: <1354043156.2701.17.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-27 at 19:05 +0000, Ben Hutchings wrote:
> On Tue, 2012-11-27 at 07:06 -0800, Eric Dumazet wrote:

> >  struct sock_common {
> > -	/* skc_daddr and skc_rcv_saddr must be grouped :
> > -	 * cf INET_MATCH() and INET_TW_MATCH()
> > +	/* skc_daddr and skc_rcv_saddr must be grouped on a 8 bytes aligned
> > +	 * address on 64bit arches : cf INET_MATCH() and INET_TW_MATCH()
> 
> __aligned(8)?

Nope, only on 64 bit this requirement exists (since a long time)

I am not sure we want complexity on this.

And we dont want holes to be automatically added here neither.
