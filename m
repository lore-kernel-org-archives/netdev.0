From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH net-next] hyperv: Add handler for
 RNDIS_STATUS_NETWORK_CHANGE event
Date: Mon, 23 Jun 2014 12:29:11 -0400
Message-ID: <20140623162911.GA20715@kroah.com>
References: <1403228076-7596-1-git-send-email-haiyangz@microsoft.com>
 <20140620045704.GA4850@aepfle.de> <20140620051213.GA9960@kroah.com>
 <ff458d1b896d4a70a32fa7709911274c@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140623080242.GA16924@aepfle.de>
 <06b508cbb6b949f4b3e13e7797948e56@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140623131723.GA7026@aepfle.de>
 <5fb9ddebb68d456ab87979b5cc3830ec@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Olaf Hering <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <5fb9ddebb68d456ab87979b5cc3830ec@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 23, 2014 at 04:09:59PM +0000, Haiyang Zhang wrote:
> 
> 
> > -----Original Message-----
> > From: Olaf Hering [mailto:olaf@aepfle.de]
> > Sent: Monday, June 23, 2014 9:17 AM
> > To: Haiyang Zhang
> > Cc: Greg KH; netdev@vger.kernel.org; jasowang@redhat.com; driverdev-
> > devel@linuxdriverproject.org; linux-kernel@vger.kernel.org;
> > davem@davemloft.net
> > Subject: Re: [PATCH net-next] hyperv: Add handler for
> > RNDIS_STATUS_NETWORK_CHANGE event
> > 
> > On Mon, Jun 23, Haiyang Zhang wrote:
> > 
> > > > I think its reasonable to expect guest config changes on this new
> > > > kind of host. Would a link-down/link-up event work? I'm sure it
> > > > will, there is enough code floating around in the guests which handles cable
> > unplug.
> > >
> > > Do you mean netif_carrier_off() / netif_carrier_on()? They are already
> > > called in the code before this patch, but DHCP renew is not triggered
> > > by them.
> > 
> > I do not know how to simulate a cable unplug. The point is that calling
> > /etc/init.d/network will fail, at least in SLES12.
> > Maybe some sort of "DHCP refresh required" event is required?
> > Maybe the DHCP clients need to renew on cable unplug?
> > No idea what the solution to the issue really is.
> 
> Yes, it will be great if there is such a "DHCP refresh required" event, or DHCP clients
> are triggered when netif_carrier_off() then netif_carrier_on().
> 
> I have tried some possibilities, like IF_OPER_DORMANT then IF_OPER_UP with 
> netdev_state_change() etc. but not able to trigger DHCP review. I will look at this
> further...
> 
> So, what's the equivalent or similar command to "network restart" on SLES12? Could
> you update the command line for the usermodehelper when porting this patch to SLES
> 12?

Given that this change will fail on all future distro releases, and
almost all of the community distros today, I don't see how this is
acceptable at all.  Nor would it be any better if you switch to a
systemd command line script as well.  You should just work like any
other network device works in this situation when it comes to
enabling/disabling the device.  Worse case, just tear down the whole
network device at suspend time, and recreate it at resume.

greg k-h
