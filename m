From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 2/2] rhashtable: Quick initial growth of tables
Date: Fri, 1 May 2015 06:30:25 +0200
Message-ID: <20150501043025.GB26676@pox.localdomain>
References: <1430434005-6143-3-git-send-email-tgraf@suug.ch>
 <20150430234556.GA31180@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:35899 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838AbbEAEa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 00:30:28 -0400
Received: by wgen6 with SMTP id n6so81962035wge.3
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 21:30:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150430234556.GA31180@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/01/15 at 07:45am, Herbert Xu wrote:
> Thomas Graf <tgraf@suug.ch> wrote:
> > Grow the table quicker than 2x in the beginning to avoid long chains
> > of rehashes. The effect is observable in the self-test where table
> > jumps are reduced to a minimum after a lot of entries have been added
> > in a short period of time. The iterator is able to get a consistent
> > view most of the time.
> > 
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Wouldn't automatic shrinking immediately undo your quick growth?

Yes, that can happen. Since shrinks are ordered to the end of the
chain it is often the case that enough entries have been added so the
shrink is not carried out in the end. Obviously this is also not the
case if no entries are actually removed.

What about we apply quick growing on >100% utilization? It is a
clear indication that we are growing rapidly.
