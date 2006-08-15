From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: bonding: cannot remove certain named devices
Date: Tue, 15 Aug 2006 15:44:44 -0700
Message-ID: <20060815154444.286e12ed@localhost.localdomain>
References: <20060815194856.GA3869@nostromo.devel.redhat.com>
	<Pine.CYG.4.58.0608151331220.3272@mawilli1-desk2.amr.corp.intel.com>
	<20060815204555.GB4434@nostromo.devel.redhat.com>
	<20060815140249.15472a82@dxpl.pdx.osdl.net>
	<20060815214914.GA5307@nostromo.devel.redhat.com>
	<Pine.CYG.4.58.0608151532070.2316@mawilli1-desk2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Bill Nottingham <notting@redhat.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:43713 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750764AbWHOWpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 18:45:03 -0400
To: Mitch Williams <mitch.a.williams@intel.com>
In-Reply-To: <Pine.CYG.4.58.0608151532070.2316@mawilli1-desk2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Aug 2006 15:41:08 -0700
Mitch Williams <mitch.a.williams@intel.com> wrote:

> On Tue, 15 Aug 2006, Bill Nottingham wrote:
> >
> > Stephen Hemminger (shemminger@osdl.org) said:
> > > > They're certainly allowed, and the sysfs directory structure, files,
> > > > etc. handle it ok. Userspace tends to break in a variety of ways.
> > > >
> > > > I believe the only invalid character in an interface name is '/'.
> > > >
> > >
> > > The names "." and ".." are also verboten.
> >
> > Right. Well, I suspect they're verboten-because-some-code-breaks-making-the-directory.
> >
> > > Names with : in them are for IP aliases.
> >
> 
> So can we use
> 	sscanf(buffer, " %[^\n]", command);
> instead?  This should allow for whitespace in the filename.  Bad interface
> names will be caught by the call to dev_valid_name().
> 
> (I think I'm reading the man page correctly.)
> 
> This could have the effect of making the parser way more finicky, though,
> since we would allow trailing whitespace.  Technically I suppose it's
> legal, but it's sure hard to see on the screen.
> 
> Anybody have a better solution?
> 
> -Mitch

IMHO idiots who put space's in filenames should be ignored. As long as the
bonding code doesn't throw a fatal error, it has every right to return
"No such device" to the fool.
