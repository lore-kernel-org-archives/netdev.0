From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] ixgb: add PCI Error recovery callbacks
Date: Thu, 6 Jul 2006 13:50:59 -0500
Message-ID: <20060706185059.GX29526@austin.ibm.com>
References: <20060629162634.GC5472@austin.ibm.com> <1151905766.28493.129.camel@ymzhang-perf.sh.intel.com> <44ABDF87.8000801@intel.com> <20060705194437.GJ29526@austin.ibm.com> <1152148899.28493.168.camel@ymzhang-perf.sh.intel.com> <20060706161640.GT29526@austin.ibm.com> <44AD4FFF.4080204@foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"bibo,mao" <bibo.mao@intel.com>,
	Rajesh Shah <rajesh.shah@intel.com>,
	Grant Grundler <grundler@parisc-linux.org>, akpm@osdl.org,
	LKML <linux-kernel@vger.kernel.org>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	netdev@vger.kernel.org, wenxiong@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:13981 "EHLO
	e33.co.us.ibm.com") by vger.kernel.org with ESMTP id S1750707AbWGFSvD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jul 2006 14:51:03 -0400
To: Auke Kok <sofar@foo-projects.org>
Content-Disposition: inline
In-Reply-To: <44AD4FFF.4080204@foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 06, 2006 at 11:01:35AM -0700, Auke Kok wrote:
> Linas Vepstas wrote:
> >
> >Perhaps the right fix is to figure out what parts of the driver do i/o
> >during shutdown, and then add a line "if(wedged) skip i/o;" to those
> >places?
> 
> that would be relatively simple if we can check a flag (?) somewhere that 
> signifies that we've encountered a pci error. We basically only need to 
> skip out after e1000_reset and bypass e1000_irq_disable in e1000_down() 
> then.
> 
> Does the pci error recovery code give us such a flag?

Yes, it was introduced so that drivers could view the state in 
an interrupt context. (how this flag is set is platform dependent.)

struct pci_dev {
         pci_channel_state error_state;
 };

enum pci_channel_state {
   /* I/O channel is in normal state */
   pci_channel_io_normal,

   /* I/O to channel is blocked */
   pci_channel_io_frozen,

   /* PCI card is dead */
   pci_channel_io_perm_failure,
};


Unless I get distracted, I'll provide an e1000 patch shortly ?

--linas
