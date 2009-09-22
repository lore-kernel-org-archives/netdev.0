From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: igb VF allocation with quirk_i82576_sriov
Date: Tue, 22 Sep 2009 08:41:54 -0700
Message-ID: <4AB8F042.4030306@intel.com>
References: <20090922051910.GC1035@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Ronciak,
	John" <john.ronciak@intel.com>
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20090922051910.GC1035@sequoia.sous-sol.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Chris Wright wrote:
> Is this known to work?  During recent virt testing for upcoming Fedora 12,
> a box w/out SR-IOV support in BIOS was using quirk to create VF BAR space,
> VF allocation worked enough to assign a device to the guest, but igbvf
> was not actually functioning properly in the guest.
> 
> Is it worth debugging this further, or is it already a known issue?

You could be experiencing one of a couple different issues.

First when you say you started SR-IOV on a box w/out SR-IOV support I 
assume you are using "pci=assign-busses" in order to reserve the bus 
space for the VFs, is that correct?  Also while your system may not 
support SR-IOV does it at least support VT-d?  Without VT-d support you 
won't be able to assign a device to the guest.

My recommendations for further testing would be to test a VF on the host 
kernel to see if that works.  If it does then you could also try direct 
assigning an entire port to see if that works.  If the entire port 
doesn't work then you probably don't have VT-d enabled.

Thanks,

Alex

------------------------------------------------------------------------------
Come build with us! The BlackBerry&reg; Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9&#45;12, 2009. Register now&#33;
http://p.sf.net/sfu/devconf
