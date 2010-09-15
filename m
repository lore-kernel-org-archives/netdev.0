From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Wed, 15 Sep 2010 11:58:37 +0200
Message-ID: <20100915095837.GA28016@redhat.com>
References: <1284410580.13351.10.camel@localhost.localdomain>
 <4C8F3C77.7010302@redhat.com>
 <1284476719.13351.35.camel@localhost.localdomain>
 <201009141721.13202.arnd@arndb.de>
 <20100914152231.GA13105@redhat.com>
 <1284480025.13351.49.camel@localhost.localdomain>
 <20100914162952.GB13560@redhat.com>
 <F2E9EB7348B8264F86B6AB8151CE2D792B8C815314@shsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shirley Ma <mashirle@us.ibm.com>, Arnd Bergmann <arnd@arndb.de>,
	Avi Kivity <avi@redhat.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <F2E9EB7348B8264F86B6AB8151CE2D792B8C815314@shsmsx502.ccr.corp.intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 15, 2010 at 10:46:02AM +0800, Xin, Xiaohui wrote:
> >From: Michael S. Tsirkin [mailto:mst@redhat.com]
> >Sent: Wednesday, September 15, 2010 12:30 AM
> >To: Shirley Ma
> >Cc: Arnd Bergmann; Avi Kivity; Xin, Xiaohui; David Miller; netdev@vger.kernel.org;
> >kvm@vger.kernel.org; linux-kernel@vger.kernel.org
> >Subject: Re: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host kernel
> >
> >On Tue, Sep 14, 2010 at 09:00:25AM -0700, Shirley Ma wrote:
> >> On Tue, 2010-09-14 at 17:22 +0200, Michael S. Tsirkin wrote:
> >> > I would expect this to hurt performance significantly.
> >> > We could do this for asynchronous requests only to avoid the
> >> > slowdown.
> >>
> >> Is kiocb in sendmsg helpful here? It is not used now.
> >>
> >> Shirley
> >
> >Precisely. This is what the patch from Xin Xiaohui does.  That code
> >already seems to do most of what you are trying to do, right?
> >
> >The main thing missing seems to be macvtap integration, so that we can fall back
> >on data copy if zero copy is unavailable?
> >How hard would it be to basically link the mp and macvtap modules
> >together to get us this functionality? Anyone?
> >
> Michael,
> Is to support macvtap with zero-copy through mp device the functionality
> you mentioned above?

I have trouble parsing the above question.  At some point Arnd suggested
that the mp device functionality would fit nicely as part of the macvtap
driver.  It seems to make sense superficially, the advantage if it
worked would be that we would get zero copy (mostly) transparently.

Do you agree with this goal?

> Before Shirley Ma has suggested to move the zero-copy functionality into
> tun/tap device or macvtap device. How do you think about that?
> I suspect
> there will be a lot of duplicate code in that three drivers except we can extract
> code of zero-copy into kernel APIs and vhost APIs.


tap would be very hard at this point as it does not bind to a device.
macvtap might work, we mainly need to figure out a way to detect that
device can do zero copy so the right mode is used.  I think a first step
could be to simply link mp code into macvtap module, pass necessary
ioctls on, then move some code around as necessary.  This might get rid
of code duplication nicely.


> Do you think that's worth to do and help current process which is blocked too
> long than I expected?

I think it's nice to have.

And if done hopefully this will get the folk working on the macvtap
driver to review the code, which will help find all issues faster.

I think if you post some performance numbers,
this will also help get people excited and looking at the code.

I also don't see the process as completely blocked, each review round points
out more issues: we aren't going back and forth changing
same lines again and again, are we?

One thing that might help is increase the frequency of updates,
try sending them out sooner.
On the other hand 10 new patches each revision is a lot:
if there is a part of patchset that has stabilised you can split it out,
post once and keep posting the changing part separately.

I hope these suggestions help.

> >
> >--
> >MST
