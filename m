From: "'Marcelo Ricardo Leitner'" <marcelo.leitner@gmail.com>
Subject: Re: [PATCH next 1/2] sctp: fix the handling of SACK Gap Ack blocks
Date: Wed, 21 Sep 2016 08:01:30 -0300
Message-ID: <20160921110130.GD9323@localhost.localdomain>
References: <cover.1474405559.git.marcelo.leitner@gmail.com>
 <18f5ac1b303b60a4363cff8e002e8fea66666a08.1474405559.git.marcelo.leitner@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0105BBB@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45282 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753168AbcIULBf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 07:01:35 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0105BBB@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2016 at 10:21:43AM +0000, David Laight wrote:
> From: Marcelo Ricardo Leitner
> > Sent: 20 September 2016 22:19
> > sctp_acked() is using 32bit arithmetics on 16bits vars, via TSN_lte()
> > macros, which is weird and confusing.
> > 
> > Once the offset to ctsn is calculated, all wrapping is already handled
> > and thus to verify the Gap Ack blocks we can just use pure
> > less/big-or-equal than checks.
> > 
> > Also, rename gap variable to tsn_offset, so it's more meaningful, as
> > it doesn't point to any gap at all.
> > 
> > Even so, I don't think this discrepancy resulted in any practical bug.
> 
> I think it might if gab.start/end are greater than 32767

Why? Mind sharing a case that it goes wrong?

  Marcelo

> 
> ...
> > -	gap = tsn - ctsn;
> > -	for (i = 0; i < ntohs(sack->num_gap_ack_blocks); ++i) {
> > -		if (TSN_lte(ntohs(frags[i].gab.start), gap) &&
> > -		    TSN_lte(gap, ntohs(frags[i].gab.end)))
> > +	blocks = ntohs(sack->num_gap_ack_blocks);
> > +	tsn_offset = tsn - ctsn;
> > +	for (i = 0; i < blocks; ++i) {
> > +		if (tsn_offset >= ntohs(frags[i].gab.start) &&
> > +		    tsn_offset <= ntohs(frags[i].gab.end))
> ...
> 
> 	David
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
