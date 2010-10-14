From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH net-next] drivers/net Documentation/networking:
 Create directory intel_wired_lan
Date: Thu, 14 Oct 2010 12:30:43 -0700
Message-ID: <1287084643.1117.602.camel@Joe-Laptop>
References: <1286743352.11039.165.camel@Joe-Laptop>
	 <AANLkTikVKufQRuMGd=cdig7ff4k2aw9Q1FWwMz3pgon-@mail.gmail.com>
	 <1286841648.26045.17.camel@Joe-Laptop>
	 <1287008906.1117.428.camel@Joe-Laptop>
	 <1287032255.4113.14.camel@jtkirshe-MOBL1>
	 <1287035857.1117.528.camel@Joe-Laptop>
	 <1287048849.3319.20.camel@jtkirshe-MOBL1>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: jeffrey.t.kirsher@intel.com, Michal Marek <mmarek@suse.cz>,
	Sam Ravnborg <sam@ravnborg.org>, linux-kbuild@vger.kernel.org
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <1287048849.3319.20.camel@jtkirshe-MOBL1>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-10-14 at 02:34 -0700, Jeff Kirsher wrote:
> On Wed, 2010-10-13 at 22:57 -0700, Joe Perches wrote:
> > On Wed, 2010-10-13 at 21:57 -0700, Jeff Kirsher wrote:
> > > On Wed, 2010-10-13 at 15:28 -0700, Joe Perches wrote:
> > > Sorry I am not ignoring you, I was taking a closer look at your patch.
> > > > What regression testing would actually be done?
> > > The Makefile and Kconfig needs more work.  I applied your patch and none
> > > of the Intel Wired drivers build.
> > Care to describe the Makefile/Kconfig issues you have seen?
> > I built it allyesconfig, defconfig, allmodconfig and allnoconfig.
> Yeah, I found all of those built without errors, but if you build the
> Intel Wired LAN drivers as modules, you will not find the *.ko files
> after the build.  The Kconfig files look fine, the problem was with the
> Makefiles.  Instead of creating a drivers/net/intel_wired_lan/Makefile,
> I simply changed the path in drivers/net/Makefile to the updated path
> and that resolved the issue.

(adding a few cc's and a link for history)

http://lkml.org/lkml/2010/10/10/207

That's the way I had done it originally as well, but I found
you couldn't build the directory with:

	make drivers/net/intel_wired_lan/

so I created a Makefile in the new directory below with
the elements necessary.

Perhaps there's some missing functionality in the build system
when the Kconfig file resides in a higher directory and the
directory being built doesn't have a Kconfig file?

I think it'd wrong to duplicate the makefile components in
2 places to allow "make subdir/" and I wonder if there's a
good solution for this.

> As far as the sub-directory name "intel_wired_lan", what about "intel"
> or "intel_wired"?  Just a thought...

Using "intel" seemed too sweeping because of the wireless drivers.
I think intel_wired_lan isn't overly long, but your choice...

Should the new (OKI?/intel) pch_gbe directory be moved as well?
It's using a PCI_VENDOR_ID_INTEL.


