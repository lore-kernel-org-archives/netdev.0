From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Structured ethtool statistic names
Date: Fri, 21 Jun 2013 16:39:05 +0100
Message-ID: <1371829145.3570.46.camel@bwh-desktop.uk.level5networks.com>
References: <1371182122-26629-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1371182122-26629-4-git-send-email-jeffrey.t.kirsher@intel.com>
	<1371666430.1956.102.camel@bwh-desktop.uk.level5networks.com>
	<FC41C24E35F18A40888AACA1A36F3E4168533EAD@FMSMSX102.amr.corp.intel.com>
	<1371758352.1946.16.camel@bwh-desktop.uk.level5networks.com>
	<FC41C24E35F18A40888AACA1A36F3E4168533F3F@FMSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, "gospo@redhat.com" <gospo@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E4168533F3F@FMSMSX102.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, 2013-06-20 at 20:04 +0000, Nelson, Shannon wrote:
> > From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> > Sent: Thursday, June 20, 2013 12:59 PM
> > 
> > On Thu, 2013-06-20 at 19:47 +0000, Nelson, Shannon wrote:
[...]
> > > When ethtool -S is called on the PF's netdev, we see both the netdev
> > > and the ports stats printed.  When called on non-PF connection we only
> > > see the netdev stats, none of the port stats.
> > 
> > Good point.  And this is something I've been meaning to bring up for
> > discussion on netdev myself - we should have some naming convention to
> > distinguish per-port and per-function/per-netdev statistics.
> 
> If you've got some ideas on a convention to use, we'd be happy to set the precedent.

OK, how about:

1. Statistic names are made up of "." separators and name components
that do not include "." or whitespace.
2. Names of statistics for the net device as a whole have a single name
component.
3. Names of statistics for the external port, where there is a useful
distinction from the net device, follow the format:
    "port." name-component.

Rationale: Only virtualised NIC drivers require a distinction, so the
convention should allow other drivers to comply without changes.
Statistics are requested on a specific net device, so that device's own
statistics should be considered primary and not given a prefix.

Since other people have been adding or proposing to add them:

4. Names of statistics for a single queue follow the format:
    queue-type "-" index "." name-component
Where queue-type is "rx" or "tx" and index is the index of the queue as
used in the kernel.

Rationale: This queue naming is consistent with the queue objects in
sysfs.

This should be extensible to allow for reading, say, VF statistics
through a PF net device, e.g. "vf-" index "." name-component.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
