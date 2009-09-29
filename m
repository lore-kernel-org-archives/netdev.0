From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2.6.31-rc9] net: VMware virtual Ethernet NIC driver: vmxnet3
Date: Tue, 29 Sep 2009 15:05:50 +0200
Message-ID: <200909291505.50961.arnd@arndb.de>
References: <89E2752CFA8EC044846EB849981913410173CDFAF6@EXCH-MBX-4.vmware.com> <20090929085333.GC3958@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Shreyas Bhatewara <sbhatewara@vmware.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	"Greg Kroah-Hartman" <greg@kroah.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	virtualization <virtualization@lists.linux-foundation.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751623AbZI2NHJ@vger.kernel.org>
In-Reply-To: <20090929085333.GC3958@sequoia.sous-sol.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 29 September 2009, Chris Wright wrote:
> > +struct Vmxnet3_MiscConf {
> > +       struct Vmxnet3_DriverInfo driverInfo;
> > +       uint64_t             uptFeatures;
> > +       uint64_t             ddPA;         /* driver data PA */
> > +       uint64_t             queueDescPA;  /* queue descriptor table PA */
> > +       uint32_t             ddLen;        /* driver data len */
> > +       uint32_t             queueDescLen; /* queue desc. table len in bytes */
> > +       uint32_t             mtu;
> > +       uint16_t             maxNumRxSG;
> > +       uint8_t              numTxQueues;
> > +       uint8_t              numRxQueues;
> > +       uint32_t             reserved[4];
> > +};
> 
> should this be packed (or others that are shared w/ device)?  i assume
> you've already done 32 vs 64 here

I would not mark it packed, because it already is well-defined on all
systems. You should add __packed only to the fields where you screwed
up, but not to structures that already work fine.

One thing that should possibly be fixed is the naming of identifiers, e.g.
's/Vmxnet3_MiscConf/vmxnet3_misc_conf/g', unless these header files are
shared with the host implementation.

	Arnd <><
