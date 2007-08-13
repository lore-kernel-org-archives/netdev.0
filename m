From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Distributed storage.
Date: Mon, 13 Aug 2007 03:12:33 -0700
Message-ID: <200708130312.33903.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708130208.57542.phillips@phunq.net> <20070813091856.GA5503@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070813091856.GA5503@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 13 August 2007 02:18, Evgeniy Polyakov wrote:
> On Mon, Aug 13, 2007 at 02:08:57AM -0700, Daniel Phillips 
(phillips@phunq.net) wrote:
> > > But that idea fails as well, since reference counts and IO
> > > completion are two completely seperate entities. So unless end IO
> > > just happens to be the last user holding a reference to the bio,
> > > you cannot free it.
> >
> > That is not a problem.  When bio_put hits zero it calls ->endio
> > instead of the destructor.  The ->endio sees that the count is zero
> > and destroys the bio.
>
> This is not a very good solution, since it requires all users of the
> bios to know how to free it.

No, only the specific ->endio needs to know that, which is set by the 
bio owner, so this knowledge lies in exactly the right place.  A small 
handful of generic endios all with the same destructor are used nearly 
everywhere.

> Right now it is hidden. 
> And adds additional atomic check (although reading is quite fast) in
> the end_io.

Actual endio happens once in the lifetime of the transfer, this read 
will be entirely lost in the noise.

> And for what purpose? To eat 8 bytes on 64bit platform? 
> This will not reduce its size noticebly, so the same number of bios
> will be in the cache's page, so what is a gain? All this cleanups and
> logic complicatins should be performed only if after size shring
> increased number of bios can fit into cache's page, will it be done
> after such cleanups?

Well, exactly,   My point from the beginning was that the size of struct 
bio is not even close to being a problem and adding a few bytes to it 
in the interest of doing the cleanest fix to a core kernel bug is just 
not a dominant issue.

I suppose that leaving out the word "bloated" and skipping straight to 
the "doesn't matter" proof would have saved some bandwidth.

Regards,

Daniel
