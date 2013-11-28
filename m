From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [[PATCH stable <3.12]] xen-netback: fix refcnt unbalance for
 3.11 and earlier versions
Date: Thu, 28 Nov 2013 13:13:46 +0000
Message-ID: <20131128131346.GK12187@zion.uk.xensource.com>
References: <1385642889-11513-1-git-send-email-wei.liu2@citrix.com>
 <1385644133.20209.11.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <stable@vger.kernel.org>,
	<tomasz.wroblewski@citrix.com>,
	Konrad Wilk <konrad.wilk@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1385644133.20209.11.camel@kazak.uk.xensource.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 28, 2013 at 01:08:53PM +0000, Ian Campbell wrote:
> On Thu, 2013-11-28 at 12:48 +0000, Wei Liu wrote:
> > With the introduction of "xen-netback: Don't destroy the netdev until
> > the vif is shut down" (upstream commit id 279f438e36), vif disconnect
> > and free are separated. However in the backported verion reference
> > counting code was not correctly modified, and the reset of vif->tx_irq
> > was lost. If frontend goes through vif life cycle more than once the
> > reference counting is skewed.
> > 
> > This patch adds back the missing tx_irq reset line. It also moves
> > several lines of the reference counting code to vif_free, so the moved
> > code corresponds to the counterpart in vif_alloc, thus the reference
> > counting is balanced.
> 
> Is this a requirement of the bugfix or just to make reasoning about
> things easier?
> 

The latter.

Wei.
