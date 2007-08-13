From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Distributed storage.
Date: Mon, 13 Aug 2007 02:55:35 -0700
Message-ID: <200708130255.35828.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708130208.57542.phillips@phunq.net> <20070813091348.GJ23758@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070813091348.GJ23758@kernel.dk>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 13 August 2007 02:13, Jens Axboe wrote:
> On Mon, Aug 13 2007, Daniel Phillips wrote:
> > On Monday 13 August 2007 00:45, Jens Axboe wrote:
> > > On Mon, Aug 13 2007, Jens Axboe wrote:
> > > > > You did not comment on the one about putting the bio
> > > > > destructor in the ->endio handler, which looks dead simple. 
> > > > > The majority of cases just use the default endio handler and
> > > > > the default destructor.  Of the remaining cases, where a
> > > > > specialized destructor is needed, typically a specialized
> > > > > endio handler is too, so combining is free.  There are few if
> > > > > any cases where a new specialized endio handler would need to
> > > > > be written.
> > > >
> > > > We could do that without too much work, I agree.
> > >
> > > But that idea fails as well, since reference counts and IO
> > > completion are two completely seperate entities. So unless end IO
> > > just happens to be the last user holding a reference to the bio,
> > > you cannot free it.
> >
> > That is not a problem.  When bio_put hits zero it calls ->endio
> > instead of the destructor.  The ->endio sees that the count is zero
> > and destroys the bio.
>
> You can't be serious? You'd stall end io completion notification
> because someone holds a reference to a bio.

Of course not.  Nothing I said stops endio from being called in the 
usual way as well.  For this to work, endio just needs to know that one 
call means "end" and the other means "destroy", this is trivial.

Regards,

Daniel
