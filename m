From: "'Marcelo Ricardo Leitner'" <marcelo.leitner@gmail.com>
Subject: Re: [PATCHv3 net-next 4/4] sctp: implement sender-side procedures
 for Add Incoming/Outgoing Streams Request Parameter
Date: Tue, 24 Jan 2017 11:10:08 -0200
Message-ID: <20170124131008.GH3781@localhost.localdomain>
References: <cover.1484845510.git.lucien.xin@gmail.com>
 <daa150a23548dda0a2fd513c622773f0ff9b2df3.1484845510.git.lucien.xin@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB026B563@AcuExch.aculab.com>
 <20170123184744.GC3781@localhost.localdomain>
 <063D6719AE5E284EB5DD2968C1650D6DB026CAC6@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Xin Long'" <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48958 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750785AbdAXNKN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 08:10:13 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB026CAC6@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 12:34:06PM +0000, David Laight wrote:
> From: Marcelo Ricardo Leitner
> > Sent: 23 January 2017 18:48
> > On Mon, Jan 23, 2017 at 11:25:56AM +0000, David Laight wrote:
> > > From: Xin Long
> > > > Sent: 19 January 2017 17:19
> > > > This patch is to implement Sender-Side Procedures for the Add
> > > > Outgoing and Incoming Streams Request Parameter described in
> > > > rfc6525 section 5.1.5-5.1.6.
> > > >
> > > > It is also to add sockopt SCTP_ADD_STREAMS in rfc6525 section
> > > > 6.3.4 for users.
> > > ...
> > > > +	out = params->sas_outstrms;
> > > > +	in  = params->sas_instrms;
> > > > +
> > > > +	if (!out && !in)
> > > > +		goto out;
> > > > +
> > > > +	if (out) {
> > > > +		__u16 nums = stream->outcnt + out;
> > >
> > > Make nums 'unsigned int', the code will be smaller and you can
> > > use the value for the overflow check.
> > 
> > Smaller as in to avoid the sum below?
> > 
> > >
> > > > +		/* Check for overflow, can't use nums here */
> > > > +		if (stream->outcnt + out > SCTP_MAX_STREAM)
> > > > +			goto out;
> 
> No, smaller as in not requiring the compiler to add instructions
> to mask (or worse sign extend) the result of the arithmetic expression
> to less than the number of bits in an 'int' when the result of the
> expression is to be kept in a register.
> 
> The x86 is about the only modern cpu that has 8 and 16 bit arithmetic.
> For everything else you really don't want to do arithmetic on char
> and short unless you really want the wrapping to happen.

Okay thanks.

  Marcelo
