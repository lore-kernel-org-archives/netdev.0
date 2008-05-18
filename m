From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10737] New: pktgen procfs problem
Date: Sat, 17 May 2008 21:56:41 -0700
Message-ID: <20080517215641.acb94677.akpm@linux-foundation.org>
References: <bug-10737-10286@http.bugzilla.kernel.org/>
	<20080517141036.d8f3c768.akpm@linux-foundation.org>
	<482F88DE.8090508@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	devzero@web.de, Robert Olsson <robert.olsson@its.uu.se>,
	"Denis V. Lunev" <den@openvz.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55492 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752113AbYERE50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 00:57:26 -0400
In-Reply-To: <482F88DE.8090508@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 18 May 2008 03:39:42 +0200 Patrick McHardy <kaber@trash.net> wrote:

> Andrew Morton wrote:
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> >
> > On Sat, 17 May 2008 13:59:25 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> >
> >   
> >> http://bugzilla.kernel.org/show_bug.cgi?id=10737
> >>
> >>            Summary: pktgen procfs problem
> >>            Product: Networking
> >>            Version: 2.5
> >>      KernelVersion: 2.6.26-rc2
> >>           Platform: All
> >>         OS/Version: Linux
> >>               Tree: Mainline
> >>             Status: NEW
> >>           Severity: normal
> >>           Priority: P1
> >>          Component: Other
> >>         AssignedTo: acme@ghostprotocols.net
> >>         ReportedBy: devzero@web.de
> >>
> >>
> >> Latest working kernel version: n/a
> >> Earliest failing kernel version: 2.6.26-rc2
> >> Distribution: suse 10.1
> >> Hardware Environment: p4 + gigabyte i915g MoBo
> >> Software Environment:
> >> Problem Description:
> >> pktgen module ocaasional seems to leak procfs entry
> >>
> >> May 18 00:00:34 test kernel: [ 2663.373955] pktgen v2.69: Packet Generator for
> >> packet performance testing.
> >> May 18 00:00:34 test kernel: [ 2663.384819] remove_proc_entry: removing
> >> non-empty directory 'net/pktgen', leaking at least 'kpktgend_1'
> >>     
> >
> > ^^
> >
> > Possibly we were always leaking this procfs entry, and newly-added
> > procfs diagnostics are now detecting it.
> >   
> 
> I've been looking into the same problem, without much success so
> far. The problem appears to affect any /proc/net file, but not
> files outside of /proc/net, so I'm guessing its net-ns related.
> A testcase found by Ben Greear is opening the file multiple times:
> 
> # /tmp/open /proc/net/kpktgen_0
> 
> => refcnt goes to 1
> 
> ^C
> 
> => refcnt goes to 0
> 
> Without ^C and opening the file a second time:
> 
> # /tmp/open /proc/net/kpktgen_0
> 
> => refcnt goes to 2 (sometimes also 11)
> 
> ^C
> 
> => refcnt stays at previous value.
> 
> The refcnt even leaks if the file can't be successfully opened,
> for example because of lacking permissions.

urgh.  Is any of this known to be post-2.6.25?
