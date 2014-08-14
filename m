From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH] Hyperv: Trigger DHCP renew after host hibernation
Date: Thu, 14 Aug 2014 05:19:12 +0000
Message-ID: <EE124450C0AAF944A40DD71E61F878C99293C4@SINEX14MBXC417.southpacific.corp.microsoft.com>
References: <DC7803B42427924284F2D5252E076A3B4476A479@SINEX14MBXC416.southpacific.corp.microsoft.com>
 <53CCD6F2.6020909@nod.at> <20140721091851.GA28171@aepfle.de>
 <20140721.143225.2040366896972949930.davem@davemloft.net>
 <CAFLxGvyfy1UkxN6_-c_ST7f8n7DvqYsCPKChWmt9CerWb0dh7g@mail.gmail.com>
 <EE124450C0AAF944A40DD71E61F878C99149D0@SINEX14MBXC417.southpacific.corp.microsoft.com>
 <20140808033220.GB10503@kroah.com>
 <EE124450C0AAF944A40DD71E61F878C991569A@SINEX14MBXC417.southpacific.corp.microsoft.com>
 <20140808134549.GD4427@kroah.com>
 <EE124450C0AAF944A40DD71E61F878C991B653@SINEX14MBXC417.southpacific.corp.microsoft.com>
 <CAG-2HqVE8Qk0pcW+36f44RkE-Kbp+qPqRT+vgg-v35W52bsKgg@mail.gmail.com>
 <EE124450C0AAF944A40DD71E61F878C9921258@SINEX14MBXC417.southpacific.corp.microsoft.com>
 <CAG-2HqWZtOk=mnsaAh5-zpWG-fv=Omq43GV9dMKHNfr1xEFQTw@mail.gmail.com>
 <1407936888.1825.0.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
 "olaf@aepfle.de" <olaf@aepfle.de>,
 Richard Weinberger <richard.weinberger@gmail.com>,
 Greg KH <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>, LKML <linux-kernel@vger.kernel.org>,
 David Miller <davem@davemloft.net>,
 "Yue Zhang \(OSTC DEV\)" <yuezha@microsoft.com>,
 Thomas Shao <huishao@microsoft.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Haiyang Zhang <haiyangz@microsoft.com>
To: Dan Williams <dcbw@redhat.com>, Tom Gundersen <teg@jklm.no>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1407936888.1825.0.camel@dcbw.local>
Content-Language: en-US
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

> -----Original Message-----
> From: Dan Williams
> > > e.g., on a bare metal host with Ubuntu 14.04, when I plug the RJ45 cable
> > > out of the network card and then plug the cable back into the network card
> > > quickly -- in ~3 seconds, networkd doesn't trigger DHCP renew request: in
> > > /var/log/syslog, we see
> > > Aug 12 11:07:07 decui-lin NetworkManager[828]: <info> (eth0): carrier
> now OFF (device state 100, deferring action for 4 seconds)
> > > Aug 12 11:07:07 decui-lin kernel: [  246.975453] e1000e: eth0 NIC Link is
> Down
> > > Aug 12 11:07:10 decui-lin NetworkManager[828]: <info> (eth0): carrier
> now ON (device state 100)
> > > Aug 12 11:07:10 decui-lin kernel: [  250.028533] e1000e: eth0 NIC Link is
> Up 100 Mbps Full Duplex, Flow Control: Rx/Tx
> > >
> > > It looks there is a delay of 4s.
> > > I'm going to find out if there is a configurable parameter for this.
> >
> > Just to avoid any confusion: you are referring to "networkd" (and so
> > did my comments), but the above logs are from "NetworkManager".
> 
> And yes, NM does have a 4-second delay before processing a carrier down
> event, and NM currently does not renew DHCP on link changes, but that's
> certainly something we can/should change.
> 
> Dan

Hi Tom, Dan,
Thanks a lot for the clarification!
So the 4s delay comes from NM rather than networkd.

Thanks,
-- Dexuan
