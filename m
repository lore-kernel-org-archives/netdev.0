From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH V2] audit: log 32-bit socketcalls
Date: Fri, 13 Jan 2017 10:18:22 -0500
Message-ID: <1484320702.5300.8.camel@redhat.com>
References: <dd937da01da72da9277e44ed79abd1f4618c14c5.1484297765.git.rgb@redhat.com>
         <1484318543.5300.1.camel@redhat.com>
         <20170113150637.GB3087@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-audit@redhat.com, Kangkook Jee <aixer77@gmail.com>,
        Paul Moore <pmoore@redhat.com>, Steve Grubb <sgrubb@redhat.com>
To: Richard Guy Briggs <rgb@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170113150637.GB3087@madcap2.tricolour.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-01-13 at 10:06 -0500, Richard Guy Briggs wrote:
> On 2017-01-13 09:42, Eric Paris wrote:
> > On Fri, 2017-01-13 at 04:51 -0500, Richard Guy Briggs wrote:


> > > diff --git a/include/linux/audit.h b/include/linux/audit.h
> > > index 9d4443f..43d8003 100644
> > > --- a/include/linux/audit.h
> > > +++ b/include/linux/audit.h
> > > @@ -387,6 +387,18 @@ static inline int audit_socketcall(int
> > > nargs,
> > > unsigned long *args)
> > >  		return __audit_socketcall(nargs, args);
> > >  	return 0;
> > >  }
> > > +static inline int audit_socketcall_compat(int nargs, u32 *args)
> > > +{
> > > +	if (unlikely(!audit_dummy_context())) {
> > 
> > I've always hated these likely/unlikely. Mostly because I think
> > they
> > are so often wrong. I believe this says that you compiled audit in
> > but
> > you expect it to be explicitly disabled. While that is (recently)
> > true
> > in Fedora I highly doubt that's true on the vast majority of
> > systems
> > that have audit compiled in.
> 
> It has been argued that audit should have pretty much no performance
> impact if it is not in use and that if it is, we're willing to take
> the
> more significant overhead of the rest of the code for the sake of one
> test to determine whether or not to follow this code path.

Ok, I can buy that argument. Not sure its where I would have settled,
but it does make sense. I'll obviously defer to Paul on what he wants
out of style. I always assume the compiler is brilliant and write
stupid code but your logic is sound there too.

You can/should pretend I said nothing.
