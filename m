From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [Regression] [2.6.35-rc1] ssb_is_sprom_available
Date: Tue, 1 Jun 2010 09:34:02 -0400
Message-ID: <20100601133402.GB26701@tuxdriver.com>
References: <201005312155.20602.maciej.rutecki@gmail.com>
 <20100531205300.GB32708@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maciej Rutecki <maciej.rutecki@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux-pci@vger.kernel.org, linux-usb@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	Michael Buesch <mb@bu3sch.de>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100531205300.GB32708@parisc-linux.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 31, 2010 at 02:53:00PM -0600, Matthew Wilcox wrote:
> On Mon, May 31, 2010 at 09:55:20PM +0200, Maciej Rutecki wrote:
> > Last known good: 2.6.34
> > Failing kernel: 2.6.35-rc1
> > 
> > subsystem: PCI, USB(?)
> > 
> > Kernel dies during booting on message "ssb_is_sprom_available", see picture:
> > http://www.unixy.pl/maciek/download/kernel/2.6.35-rc1/gumis/DSC_0011.JPG
> 
> Um, looks like it's something to do with the Sonics Silicon Backplane,
> not PCI, nor USB.

Fix is on its way...

commit da1fdb02d9200ff28b6f3a380d21930335fe5429
Author: Christoph Fritz <chf.fritz@googlemail.com>
Date:   Fri May 28 10:45:59 2010 +0200

    ssb: fix NULL ptr deref when pcihost_wrapper is used
    
    Ethernet driver b44 does register ssb by it's pcihost_wrapper
    and doesn't set ssb_chipcommon. A check on this value
    introduced with commit d53cdbb94a52a920d5420ed64d986c3523a56743
    and ea2db495f92ad2cf3301623e60cb95b4062bc484 triggers:
    
    BUG: unable to handle kernel NULL pointer dereference at 00000010
    IP: [<c1266c36>] ssb_is_sprom_available+0x16/0x30
    
    Signed-off-by: Christoph Fritz <chf.fritz@googlemail.com>
    Signed-off-by: John W. Linville <linville@tuxdriver.com>

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
