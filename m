From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH V4 4/7] Drivers: hv: vmbus: add APIs to register callbacks
 to process hvsock connection
Date: Thu, 6 Aug 2015 18:28:18 +0000
Message-ID: <SN1PR0301MB1662D4C6D4EA3F82FAA4C4C7A0740@SN1PR0301MB1662.namprd03.prod.outlook.com>
References: <1438086911-19384-1-git-send-email-decui@microsoft.com>
 <20150729.152651.331017965932467028.davem@davemloft.net>
 <f65ab29ed3d0488685afdca2dd2189a9@SIXPR30MB031.064d.mgd.msft.net>
 <115a97288d1e4c239fcbaab28298c552@SIXPR30MB031.064d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "stephen@networkplumber.org" <stephen@networkplumber.org>,
 "stefanha@redhat.com" <stefanha@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "pebolle@tiscali.nl" <pebolle@tiscali.nl>,
 "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>
To: Dexuan Cui <decui@microsoft.com>, David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <115a97288d1e4c239fcbaab28298c552@SIXPR30MB031.064d.mgd.msft.net>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Dexuan Cui
> Sent: Wednesday, August 5, 2015 9:54 PM
> To: David Miller <davem@davemloft.net>; KY Srinivasan
> <kys@microsoft.com>
> Cc: olaf@aepfle.de; gregkh@linuxfoundation.org; jasowang@redhat.com;
> driverdev-devel@linuxdriverproject.org; linux-kernel@vger.kernel.org;
> stephen@networkplumber.org; stefanha@redhat.com;
> netdev@vger.kernel.org; apw@canonical.com; pebolle@tiscali.nl;
> dan.carpenter@oracle.com
> Subject: RE: [PATCH V4 4/7] Drivers: hv: vmbus: add APIs to register callbacks
> to process hvsock connection
> 
> > From: devel [mailto:driverdev-devel-bounces@linuxdriverproject.org] On
> Behalf
> > Of Dexuan Cui
> > Sent: Thursday, July 30, 2015 18:20
> > To: David Miller <davem@davemloft.net>; KY Srinivasan
> <kys@microsoft.com>
> > Cc: olaf@aepfle.de; gregkh@linuxfoundation.org; jasowang@redhat.com;
> > driverdev-devel@linuxdriverproject.org; linux-kernel@vger.kernel.org;
> > stephen@networkplumber.org; stefanha@redhat.com;
> netdev@vger.kernel.org;
> > apw@canonical.com; pebolle@tiscali.nl; dan.carpenter@oracle.com
> > Subject: RE: [PATCH V4 4/7] Drivers: hv: vmbus: add APIs to register
> callbacks to
> > process hvsock connection
> >
> > > From: David Miller
> > > Sent: Thursday, July 30, 2015 6:27
> > >
> > > From: Dexuan Cui
> > > Date: Tue, 28 Jul 2015 05:35:11 -0700
> > >
> > > > With the 2 APIs supplied by the VMBus driver, the coming net/hvsock
> driver
> > > > can register 2 callbacks and can know when a new hvsock connection is
> > > > offered by the host, and when a hvsock connection is being closed by
> the
> > > > host.
> > > >
> > > This is an extremely terrible interface.
> > >
> > > It's an opaque hook that allows on registry, and it's solve purpose
> > > is to allow a backdoor call into a foreign driver in another module.
> > >
> > > These are exactly the things we try to avoid.
> >
> > Hi David,
> > Thanks a lot for your reviewing and the suggestion!
> >
> > > Why not create a real abstraction where clients register an object,
> > > that can be contained as a sub-member inside of their own driver
> > > private, that provides the callback registry mechanism.
> 
> Hi David,
> Can you please have a look at my below questions?
> 
> I like your idea of a real abstraction. Your answer would definitely
> help me to implement that correctly.
> 
> > Please pardon me for my inexperience.
> > Can you please be a bit more specific?
> > I guess maybe you're referencing a common design pattern in the driver
> > code, so an example in some existing driver would be the best. :-)
> >
> > "clients register an object " --
> > does the "clients" mean the hvsock driver?
> > and the "object" means the 2 callbacks?
> >
> > IMHO, here the vmbus driver has to synchronously pass the 2 events
> > to the hvsock driver, so a "backdoor call into the hvsock driver" is
> > inevitable anyway?
> >
> > e.g., in the path vmbus_process_offer() -> hvsock_process_offer(), the
> > return value of the latter is important to the former, because on error
> > the former needs to clean up some internal states of the vmbus driver
> (that
> > is, the "goto err_deq_chan").
> >
> >
> > > That way you can register multiple clients, do things like allow
> > > AF_PACKET capturing of vmbus traffic, etc.
> >
> > I thought AF_PACKET can only capture IP packetsor Ethernet frames.
> > Can it be used to capture AF_UNIX packet?
> > If yes, I suppose we can consider making it work for AF_HYPERV too,
> > if people ask for that.
> >

Dexuan,

The notion of a channel on Hyper-V has been mapped to a device on Linux and the mechanism we have
had of notifying the driver of the creation of the channel was through registering this device with the kernel
(vmbus_device_create). The first exception to this was when we introduced multi-channel support that broke
the assumption of this one to one mapping between the channel and Linux device. In the case of the sub-channels,
we handled the  driver notification issue via the sub-channel callback that the driver registers at the point of 
opening the channel. Perhaps we could make the sub-channel handling mechanism more generic to handle the case
of VMSOCK as well?

Regards,

K. Y
> > -- Dexuan
> 
> Thanks,
> -- Dexuan
