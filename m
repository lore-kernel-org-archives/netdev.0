From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH] sctp:Make the function sctp_assoc_lookup_laddr bool
Date: Fri, 5 Jun 2015 14:16:25 -0300
Message-ID: <20150605171625.GB3402@localhost.localdomain>
References: <1433335867-1871-1-git-send-email-xerofoify@gmail.com>
 <20150604103503.GA24585@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicholas Krause <xerofoify@gmail.com>, vyasevich@gmail.com,
	davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52001 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752066AbbFERQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jun 2015 13:16:29 -0400
Content-Disposition: inline
In-Reply-To: <20150604103503.GA24585@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 04, 2015 at 06:35:03AM -0400, Neil Horman wrote:
> On Wed, Jun 03, 2015 at 08:51:07AM -0400, Nicholas Krause wrote:
> > This makes the function sctp_assoc_lookup_laddr bool due to this
> > function only returning either one or zero as its return value.
> > 
> > Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> > ---
> >  include/net/sctp/structs.h | 4 ++--
> >  net/sctp/associola.c       | 8 ++++----
> >  2 files changed, 6 insertions(+), 6 deletions(-)
> > 
> > diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> > index 2bb2fcf..1381be9 100644
> > --- a/include/net/sctp/structs.h
> > +++ b/include/net/sctp/structs.h
> > @@ -1870,8 +1870,8 @@ struct sctp_transport *sctp_assoc_choose_alter_transport(
> >  void sctp_assoc_update_retran_path(struct sctp_association *);
> >  struct sctp_transport *sctp_assoc_lookup_paddr(const struct sctp_association *,
> >  					  const union sctp_addr *);
> > -int sctp_assoc_lookup_laddr(struct sctp_association *asoc,
> > -			    const union sctp_addr *laddr);
> > +bool sctp_assoc_lookup_laddr(struct sctp_association *asoc,
> > +			     const union sctp_addr *laddr);
> >  struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *,
> >  				     const union sctp_addr *address,
> >  				     const gfp_t gfp,
> > diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> > index 197c3f5..69abe78 100644
> > --- a/net/sctp/associola.c
> > +++ b/net/sctp/associola.c
> > @@ -1572,15 +1572,15 @@ int sctp_assoc_set_bind_addr_from_cookie(struct sctp_association *asoc,
> >  }
> >  
> >  /* Lookup laddr in the bind address list of an association. */
> > -int sctp_assoc_lookup_laddr(struct sctp_association *asoc,
> > -			    const union sctp_addr *laddr)
> > +bool sctp_assoc_lookup_laddr(struct sctp_association *asoc,
> > +			     const union sctp_addr *laddr)
> >  {
> > -	int found = 0;
> > +	bool found = false;
> >  
> >  	if ((asoc->base.bind_addr.port == ntohs(laddr->v4.sin_port)) &&
> >  	    sctp_bind_addr_match(&asoc->base.bind_addr, laddr,
> >  				 sctp_sk(asoc->base.sk)))
> > -		found = 1;
> > +		found = true;
> >  
> >  	return found;
> >  }
> > -- 
> > 2.1.4
> > 
> > 
> 
> If you're going to do this, you might as well also remove the conditional
> statement here entirely.  I.e. just have the function be this:
> 
> return (asoc->base.bind_addr.port == ntohs(laddr->v4.sin_port)) &&
> 	sctp_bind_addr_match(&asoc->base.bind_addr, laddr,
> 	sctp_sk(asoc->base.sk)));
> 
> You might also look into makeing it inline, though it doesn't appear in any hot
> paths so thats likely overkill

+1
just in case you cut&paste, be careful that the 3rd line should start
right after the ( in the 2nd line. (Like it was before)

  Marcelo
