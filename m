From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [PATCH 1/2 V3] PCI: introduce device assignment
 interface and refactory related code
Date: Sun, 20 Jul 2014 19:58:36 -0600
Message-ID: <1405907916.4463.2.camel@ul30vt.home>
References: <1405081802-419-1-git-send-email-ethan.zhao@oracle.com>
	<1405084407.4098.59.camel@ul30vt.home>
	<1405088147.4098.64.camel@ul30vt.home>
	<B5657A6538887040AD3A81F1008BEC63B020DC@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	linux-pci <linux-pci@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"vaughan.cao@oracle.com" <vaughan.cao@oracle.com>,
	"jesse.brandeburg@intel.com" <jesse.brandeburg@intel.com>,
	"ethan.kernel@gmail.com" <ethan.kernel@gmail.com>,
	Ethan Zhao <ethan.zhao@oracle.com>,
	"linux.nics@intel.com" <linux.nics@intel.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"gleb@kernel.org" <gleb@kernel.org>,
	"bhelgaas@google.com" <bhelgaas@google.com>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
	netdev <netdev@vger.kernel.org>,
	"bruce.w.allan@intel.com" <bruce.w.allan@intel.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"john.ronciak@intel.com" <john.ronciak@intel.com>,
	"david.vrabel@citrix.com" <david.vrabel@citrix.com>,
	"pbonzini@redhat.com" <pbonzini@redhat.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63B020DC@avmb3.qlogic.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sun, 2014-07-20 at 14:48 +0000, Yuval Mintz wrote:
> > On Fri, 2014-07-11 at 07:13 -0600, Alex Williamson wrote:
> > > On Fri, 2014-07-11 at 20:30 +0800, Ethan Zhao wrote:
> > > > This patch introduces two new device assignment functions
> > > >
> > > > pci_iov_assign_device(),
> > > > pci_iov_deassign_device()
> > > >
> > > > along with the existed one
> > > >
> > > > pci_vfs_assigned()
> > > >
> > > > They construct the VFs assignment management interface, used to
> > > > assign/ deassign device to VM and query the VFs reference counter.
> > > > instead of direct manipulation of device flag.
> 
> Sorry for the late intrusion into the conversation, and perhaps it's a bit
> unrelated, but given that you're creating a 'VF assignment management'
> perhaps it's the right place to add some sort of mechanism in order to
> prevent module removal once one of its VFs is assigned.
> [e.g., incrementing module reference count]
> 
> At the moment [to the best of my knowledge] there's no mechanism
> preventing the 'not-so-bright' user from removing the driver, and no good
> will come out of it.

On what module would the reference count be increased, the PF?  The
entire "VF assigned" interface is a hack to work around poor
architectures like legacy KVM device assignment where there's no proper
device owner for the VF.  This is "fixed" by using VFIO instead and
hopefully deprecating legacy KVM assignment.  Thanks,

Alex


------------------------------------------------------------------------------
Want fast and easy access to all the code in your enterprise? Index and
search up to 200,000 lines of code with a free copy of Black Duck
Code Sight - the same software that powers the world's largest code
search on Ohloh, the Black Duck Open Hub! Try it now.
http://p.sf.net/sfu/bds
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
