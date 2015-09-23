From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2] netpoll: Close race condition between poll_one_napi
 and napi_disable
Date: Wed, 23 Sep 2015 06:39:00 -0400
Message-ID: <20150923103859.GA29016@hmsreliant.think-freely.org>
References: <20150922190154.GC31679@hmsreliant.think-freely.org>
 <1442952096-31430-1-git-send-email-nhorman@redhat.com>
 <20150922150920.2a830e62@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@redhat.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50050 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752968AbbIWKjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 06:39:15 -0400
Content-Disposition: inline
In-Reply-To: <20150922150920.2a830e62@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 22, 2015 at 03:09:20PM -0700, Stephen Hemminger wrote:
> On Tue, 22 Sep 2015 16:01:36 -0400
> Neil Horman <nhorman@redhat.com> wrote:
> 
> > +	clear_bit(NAPI_STATE_NPSVC, &n->state);
> > +
> >  }
> why introduce extra line here?
> 
> > +	/*
> > +	 * If we set this bit but see that it has already been set,
> > +	 * that indicates that napi has been disabled and we need
> > +	 * to abort this operation
> > + 	 */
> > +
> > +	if(test_and_set_bit(NAPI_STATE_NPSVC, &napi->state))
> 
> And why introduce line after comment before code.
> My preference is to have comment as close to code as possible.

Mine is to add spaces, as I feel the code is more readable if its a bit more
spread out.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
