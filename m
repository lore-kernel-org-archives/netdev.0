From: "'Marcelo Ricardo Leitner'" <marcelo.leitner@gmail.com>
Subject: Re: [PATCH next] sctp: make use of WORD_TRUNC macro
Date: Fri, 16 Sep 2016 08:35:57 -0300
Message-ID: <20160916113557.GC3200@localhost.localdomain>
References: <b40b1bd4adff2d389588d9a4710af0399ce68d1e.1473963064.git.marcelo.leitner@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB00FF62C@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59650 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1765382AbcIPLgB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Sep 2016 07:36:01 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB00FF62C@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 16, 2016 at 09:51:56AM +0000, David Laight wrote:
> From: Marcelo Ricardo Leitner
> > Sent: 15 September 2016 19:13
> > No functional change. Just to avoid the usage of '&~3'.
> ...
> > -	max_data = (asoc->pathmtu -
> > -		sctp_sk(asoc->base.sk)->pf->af->net_header_len -
> > -		sizeof(struct sctphdr) - sizeof(struct sctp_data_chunk)) & ~3;
> > +	max_data = asoc->pathmtu -
> > +		   sctp_sk(asoc->base.sk)->pf->af->net_header_len -
> > +		   sizeof(struct sctphdr) - sizeof(struct sctp_data_chunk);
> > +	max_data = WORD_TRUNC(max_data);
> 
> Hmmm....
> Am I the only person who understands immediately what & ~3 does
> but would have to grovel through the headers to find exactly what
> WORD_TRUNC() does.
> 

ctags & cia can help you with that. :)

> How big is a 'WORD' anyway??

That's pretty much one of the reasons for using the macro, to make sure
it is correctly adapted to some arch if necessary. (even though it's
not necessary in this case)

  Marcelo
