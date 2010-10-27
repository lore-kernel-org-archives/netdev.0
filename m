From: Simon Horman <horms@verge.net.au>
Subject: Re: [Bugme-new] [Bug 20772] New: ip= nfsaddrs= stopped working
Date: Thu, 28 Oct 2010 07:31:32 +0900
Message-ID: <20101027223103.GA10484@verge.net.au>
References: <bug-20772-10286@https.bugzilla.kernel.org/>
 <20101019120938.93622e82.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, mpetersen@peak6.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:58435 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932356Ab0J1Heg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 03:34:36 -0400
Content-Disposition: inline
In-Reply-To: <20101019120938.93622e82.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 19, 2010 at 12:09:38PM -0700, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Tue, 19 Oct 2010 18:20:15 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=20772
> > 
> >            Summary: ip= nfsaddrs= stopped working
> >            Product: Networking
> >            Version: 2.5
> >     Kernel Version: 2.6.33, 2.6.32, 2.6.26
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: high
> >           Priority: P1
> >          Component: IPV4
> >         AssignedTo: shemminger@linux-foundation.org
> >         ReportedBy: mpetersen@peak6.com
> >         Regression: Yes
> > 
> > 
> > I can no longer set a static IP address using either ip= or nfsaddr=,
> > ie ip=192.168.0.42:192.168.0.69:255.255.255.0:testhost:eth0:none has no
> > effect, and DHCP is still attempted.
> > 
> > Even if I undefine IP_PNP_DHCP IP_PNP_BOOTP and IP_PNP_RARP in the
> > config (but leave IP_PNP,) the kernel seems to ignore the static IP
> > settings and try to get a an IP address with DHCP somehow.

Hi,

I believe that the problem is that there is a minor syntax error in the
configuration parameter. Specifically there should be two colons between
192.168.0.69 and 255.255.255.0 or between 192.168.0.42 and 192.168.0.69.

As it stands the settings are:

	my address	192.168.0.42
	server address	192.168.0.69
	gateway		255.255.255.0
	netmask		testhost
	hostname	eth0
	interface	none

I believe it is the interface=none that is killing any IP configuration
by the kernel as no such interface exists.
