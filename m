From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 2/2] rhashtable: Quick initial growth of tables
Date: Fri, 1 May 2015 15:38:01 +0200
Message-ID: <20150501133801.GA5784@pox.localdomain>
References: <1430434005-6143-3-git-send-email-tgraf@suug.ch>
 <20150430234556.GA31180@gondor.apana.org.au>
 <20150501043025.GB26676@pox.localdomain>
 <20150501043725.GA927@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:35599 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753543AbbEANiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 09:38:05 -0400
Received: by widdi4 with SMTP id di4so52882030wid.0
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 06:38:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150501043725.GA927@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/01/15 at 12:37pm, Herbert Xu wrote:
> On Fri, May 01, 2015 at 06:30:25AM +0200, Thomas Graf wrote:
> >
> > Yes, that can happen. Since shrinks are ordered to the end of the
> > chain it is often the case that enough entries have been added so the
> > shrink is not carried out in the end. Obviously this is also not the
> > case if no entries are actually removed.
> 
> It's just a matter of logical consistency.  At 75% if you grow by
> a factor of 4, you get 18.75% utilisation which is way below the
> 30% shrink threshold.
> 
> > What about we apply quick growing on >100% utilization? It is a
> > clear indication that we are growing rapidly.
> 
> Even at 100%, a factor of 4 leads you to 25% which is less than 30%.
> 
> Perhaps we could lower the shrink thresholds? Alternatively, only
> grow quickly if automatic shrinking is disabled.  After all, the one
> case that's inspring all of this, netlink really wants to grow
> quickly as well as only shrink at specific points in time.

Lowering the shrink threshold in combination with quick growth
above 100% sounds good to me. The whole point of this is to detect
when we are likely to see a lot of inserts with only a few or no
removals.
