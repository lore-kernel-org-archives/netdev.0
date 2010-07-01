From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: TCP not triggering a fast retransmit?
Date: Thu, 01 Jul 2010 02:23:53 +0100
Message-ID: <1277947433.4878.11.camel@localhost>
References: <AANLkTinJC6uS1GTbKJWL9AlEs2e5GleQvJbTUZrsQHaE@mail.gmail.com>
	 <1277931829.4878.9.camel@localhost>
	 <AANLkTimL7_h4J46-WyUYfXYX87t6tQzIn1YRrvJletWB@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmatthews@greenplum.com,
	Tim Heath <theath@greenplum.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Ivan Novick <novickivan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:47428 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914Ab0GABX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 21:23:58 -0400
In-Reply-To: <AANLkTimL7_h4J46-WyUYfXYX87t6tQzIn1YRrvJletWB@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-30 at 17:27 -0700, Ivan Novick wrote:
> On Wed, Jun 30, 2010 at 2:03 PM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> > On Wed, 2010-06-30 at 11:04 -0700, Ivan Novick wrote:
> >> Hello all,
> >>
> >> Attached is a packet capture from my application that is running on
> >> RedHat Enterprise Linux 5.4
> >>
> >> I am seeing a Retransmission timeout but I was hoping this case would
> >> go into fast retransmit and not RTO.
> >>
> >> I am wondering why did the sender not send more data?  If the sender
> >> was to send more data and extend the window then it would seem the
> >> duplicate acks or SACKS should trigger fast retransmit.
> > [...]
> >
> > In that packet capture I see TCP payload lengths which are 2, 3 and 4
> > times the usual MSS of 1448 bytes, which implies that GRO or LRO is in
> > use.  In RHEL 5.4 the TCP stack does not ACK often enough in this case
> > because it is missing this change:
> >
> > commit ff9b5e0f08cb650d113eef0c654f931c0a7ae730
> > Author: Herbert Xu <herbert@gondor.apana.org.au>
> > Date:   Thu Aug 31 15:11:02 2006 -0700
> >
> >    [TCP]: Fix rcv mss estimate for LRO
> 
> Wow, Thanks! Is this the patch you are talking about:
> http://www.mail-archive.com/netdev@vger.kernel.org/msg21151.html  ?
> 
> It looks like a one liner.   I could apply it and rebuild my RHEL 5.4
> to see if it helps.

Right, that's the same patch.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

