From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH, v2] Xen: consolidate and simplify struct xenbus_driver
 instantiation
Date: Tue, 3 Jan 2012 15:36:38 -0500
Message-ID: <20120103203637.GF17472@phenom.dumpdata.com>
References: <4EF3018D020000780006986E@nat28.tlf.novell.com>
 <1324547820.7877.71.camel@zakaz.uk.xensource.com>
 <4EF327E2020000780006993E@nat28.tlf.novell.com>
 <1324555060.7877.84.camel@zakaz.uk.xensource.com>
 <1324565067.2897.2.camel@bwh-desktop>
 <1324586301.13113.3.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Jan Beulich <JBeulich@suse.com>,
	Konrad Rzeszutek Wilk <konrad@darnok.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"dmitry.torokhov@gmail.com" <dmitry.torokhov@gmail.com>,
	"FlorianSchandinat@gmx.de" <FlorianSchandinat@gmx.de>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Jens Axboe <axboe@kernel.dk>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1324586301.13113.3.camel@dagon.hellion.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 22, 2011 at 08:38:21PM +0000, Ian Campbell wrote:
> On Thu, 2011-12-22 at 14:44 +0000, Ben Hutchings wrote:
> > On Thu, 2011-12-22 at 11:57 +0000, Ian Campbell wrote:
> > > On Thu, 2011-12-22 at 11:51 +0000, Jan Beulich wrote:
> > > > >>> On 22.12.11 at 10:57, Ian Campbell <Ian.Campbell@citrix.com> wrote:
> > > > > On Thu, 2011-12-22 at 09:08 +0000, Jan Beulich wrote:
> > > > >> The 'name', 'owner', and 'mod_name' members are redundant with the
> > > > >> identically named fields in the 'driver' sub-structure. Rather than
> > > > >> switching each instance to specify these fields explicitly, introduce
> > > > >> a macro to simplify this.
> > > > >> 
> > > > >> Eliminate further redundancy by allowing the drvname argument to
> > > > >> DEFINE_XENBUS_DRIVER() to be blank (in which case the first entry from
> > > > >> the ID table will be used for .driver.name).
> > > > > 
> > > > > Any reason not to always use DRV_NAME here (which is generally a bit
> > > > > more specific e.g. "xen-foofront" rather than "foo") and rely on the id
> > > > > table for the shorter names used in xenstore?
> > > > 
> > > > That would imply that DRV_NAME is always defined, but I don't
> > > > see this being the case.
> > > 
> > > My mistake, I thought it was a Kbuild thing.
> > 
> > You're maybe thinking of KBUILD_MODNAME.
> 
> Yes, I think I was.

Ian, are you OK with this patch? I think Jan needs to repost once more with the
"pciback" -> DRV_NAME change and then it is OK?

I've tested it with all backends, except the pciback one, and I see no regressions
with 'xl' or 'xm' toolstack.
