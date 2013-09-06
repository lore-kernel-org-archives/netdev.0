From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [E1000-devel] [net-next v5 8/8] i40e: include i40e in kernel
 proper
Date: Fri, 6 Sep 2013 17:28:09 +0000
Message-ID: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D5C3B0A3D@FMSMSX113.amr.corp.intel.com>
References: <1378447278-13998-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1378447278-13998-9-git-send-email-jeffrey.t.kirsher@intel.com>
	 ,<20130905231436.761d03c3@nehalam.linuxnetplumber.net>
	 <C0F8C5F1-0D98-4297-ACC9-55BB9C889FEB@intel.com>
 <1378450038.19204.6.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Joe Perches <joe@perches.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56896 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750721Ab3IFR2e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 13:28:34 -0400
In-Reply-To: <1378450038.19204.6.camel@joe-AO722>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
> Behalf Of Joe Perches
> Sent: Thursday, September 05, 2013 11:47 PM
> To: Brandeburg, Jesse
> Cc: Stephen Hemminger; Kirsher, Jeffrey T; davem@davemloft.net; e1000-
> devel@lists.sourceforge.net; netdev@vger.kernel.org; gospo@redhat.com;
> sassmann@redhat.com
> Subject: Re: [E1000-devel] [net-next v5 8/8] i40e: include i40e in kernel
> proper
> 
> On Fri, 2013-09-06 at 06:28 +0000, Brandeburg, Jesse wrote:
> > On Sep 5, 2013, at 11:15 PM, "Stephen Hemminger"
> <stephen@networkplumber.org<mailto:stephen@networkplumber.org>> wrote:
> >
> > Dumb question why is this named Kbuild instead of Makefile like almost
> > every other network driver?
> >
> > All the new kids are doing it, we'll at least that is what I thought when
> I made it.
> >
> > Re-reading https://www.kernel.org/doc/Documentation/kbuild/makefiles.txt
> >
> > I see that Makefile is preferred but Kbuild overrides Makefile.
> >
> > Either way works, but I would prefer not to rename it at this point but
> would gladly do so in a follow up patch
> 
> Please do.
> 
> I suppose it makes _some_ sense to use Kbuild in the
> include paths but I think Makefile in places where
> compilations are done is better.
> 

That was me. I did it to make things less confusing for our customers and for us as engineers.

My goal was to make our out-of-tree driver as close as possible - including the makefiles - to the upstream driver. Doing this makes it simpler for us to backport and forward-port patches. It makes it less confusing for us when we're moving from one environment to the other.

The Kbuild file submitted here is exactly the same file that will be included in our out-of-tree tarball. To avoid confusion, I named it Kbuild, so nobody would just run make in the source directory. The toplevel makefile in our tarball is named Makefile, and I wanted that to be the only Makefile around so nobody would be confused (including me).

The kernel documentation specifically states that this is acceptable (Documentation/kbuild/modules.txt). Furthermore, Documentation/kbuild/makefiles.txt states that using Kbuild as a filename is acceptable.

Personally, I'd prefer to keep these named Kbuild. Doing so makes it simpler to keep our in-tree and out-of-tree drivers in sync. But if you're really passionate about having them named Makefile, we can deal with it. It's just one more detail for us to keep track of (and potentially screw up).

If there is a hard requirement that these files be named Makefile, then I would request that the kernel documentation be updated to reflect this.

-Mitch
