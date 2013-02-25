From: Paul Moore <pmoore@redhat.com>
Subject: Re: AF_VSOCK and the LSMs
Date: Mon, 25 Feb 2013 16:05:39 -0500
Message-ID: <1495862.ttoqQE2oSv@sifl>
References: <1803195.0cVPJuGAEx@sifl> <5429810.RVpOLLsSs4@sifl> <512BA742.5050304@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, Andy King <acking@vmware.com>,
	Gerd Hoffmann <kraxel@redhat.com>,
	Eric Paris <eparis@redhat.com>
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <512BA742.5050304@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, February 25, 2013 10:02:42 AM Casey Schaufler wrote:
> On 2/25/2013 8:55 AM, Paul Moore wrote:
> > [NOTE/WARNING: we're veering away from the VSOCK discussion and towards a
> > LSM stacking discussion; see my response to Gerd if you want to stay on
> > topic.]> 
> > On Saturday, February 23, 2013 03:43:23 PM Casey Schaufler wrote:
> >> On 2/22/2013 4:45 PM, Paul Moore wrote:
> >>> On Friday, February 22, 2013 03:00:04 PM Casey Schaufler wrote:
> >>>> Please add an LSM blob. Please do not use a secid. I am currently
> >>>> battling with secids in my efforts for multiple LSM support.
> >>>> 
> >>>> ...
> >>>> 
> >>>> I am going to be able to deal with secids for AF_INET only because
> >>>> SELinux prefers XFRM, Smack requires CIPSO, and AppArmor is going to
> >>>> be willing to have networking be optional.
> >>> 
> >>> "prefers"?  Really Casey, did you think I would let you get away with
> >>> that statement?  What a LSM "prefers" is really not relevant to the
> >>> stacking effort, what a LSM _supports_ is what matters.
> >> 
> >> I suppose. My point, which you may refute if it is incorrect,
> >> is that there are common, legitimate SELinux configurations which
> >> eschew Netlabel in favor of XFRM.
> > 
> > There are common, legitimate use cases which use exclusively NetLabel,
> > exclusively labeled IPsec, and both.  A LSM stacking design that forces
> > SELinux to only operate with XFRM (labeled IPsec) is wrong.  If you are
> > giving admins the ability to selectively stack LSMs you should also allow
> > them to selectively pick which non-shareable functionality they assign to
> > each LSM.
>
> That is the approach I'm taking. The kernel configuration
> will specify which LSM gets Netlabel and which gets XFRM.

Okay, it wasn't obvious to me in your previous emails that this was the case. 
Also, just so I'm clear, you configure the stacking and the stacked network 
access controls at the same time, yes?  I want to avoid the situation where 
the stacked network access controls are determined at build time and the LSM 
stacking order/configuration is determined at boot.
 
> >>> If you want to try option #3 I think we might be able to do something
> >>> with NetLabel to support multiple LSMs as the label abstraction stuff
> >>> should theoretically make this possible; although the NetLabel cache
> >>> will need some work.
> >> 
> >> It is reasonably easy to restrict Netlabel to a single LSM,
> >> and since SELinux seems better served by XFRM in most configurations ...
> > 
> > I disagree.  In some use cases SELinux is better served by XFRM, in others
> > it is better served by NetLabel.  Once again, I think you need to focus
> > on what is possible with the LSMs rather than a particular set of use
> > cases which happen to make the LSM stacking project easier.
> 
> I'm trying not to make too many architectural changes to the
> code around the LSM mechanism itself. I don't see that as cost
> effective or likely to be popular. If the implication of that is
> that there are certain configurations that are unsupportable but
> that have plausible alternatives I think it will do for phase I.

That statement is vague enough that I can't really say yes or no to it, but I 
will stick by my previous comments about the network access controls.

> >> Options I have considered include:
> >> 	- Netlabel support for discriminating LSM use by host,
> >> 	
> >> 	  just as it currently allows for unlabeled hosts.
> > 
> > Hmm, interesting ... not sure what I think of this.
> 
> It breaks down on 127.0.0.1. Otherwise is looks pretty easy to do.

When I said I wasn't sure what I thought of this, it was more along the lines 
of I'm not sure if it makes sense, not that it would be difficult to do.
 
> >> 	- secid maps.
> > 
> > Can you elaborate on this?  I can think of a few different meanings here
> > ...
>
> This fell out of my first shot at stacking, the one that never saw
> the light of day for tax reasons. I had implemented a stacker LSM
> that slid into the existing infrastructure. Hooks that asked for
> secids got the secid from my LSM, not the underlying LSM secids.
> There was a table much like the Smack label list that mapped the
> global secids to sets of underlying secids. The obvious problem
> is that that table grows quickly and can never go away.

Interesting idea, but I can imagine it gets rather intrusive very quickly.
 
-- 
paul moore
security and virtualization @ redhat

