From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Error: an inet prefix is expected rather than "0/0".
Date: Tue, 14 Oct 2008 10:46:21 -0700
Message-ID: <20081014104621.3c2ce4d3@extreme>
References: <alpine.LNX.1.10.0810082331010.13921@bizon.gios.gov.pl>
	<E1KpkSl-00087W-GB@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ole@ans.pl (Krzysztof Oledzki), netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52231 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751122AbYJNRq1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Oct 2008 13:46:27 -0400
In-Reply-To: <E1KpkSl-00087W-GB@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Oct 2008 22:01:27 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Krzysztof Oledzki <ole@ans.pl> wrote:
> >
> > http://git.kernel.org/?p=linux/kernel/git/shemminger/iproute2.git;a=commitdiff_plain;h=2ca4abdcb823e708b88156f947fa5b493055618a
> > 
> > ;)
> 
> Hmm, this breaks several scripts of mine that use 10/8.  Couldn't
> we just fall back to the old loop when inet_aton fails?
> 
> Thanks,


There is no easy solution, I'll will have to go back rewrite this
code, and will document the result. I expect the result will displease
someone, but given the original code that is just going to happen.

Busted cases:
                           correct           incorrect
Original code: 127.2   =>  127.0.0.2         127.2.0.0
inet_pton:     10.0    =>  10.0.0.0          fails invalid
inet_aton:     10      =>  10.0.0.0          0.0.0.10

The problem was Alexey (or Jamal) invented their own abbreviation format
and did not follow unix standard conventions.
