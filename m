From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] Hyperv: Trigger DHCP renew after host hibernation
Date: Thu, 7 Aug 2014 20:32:20 -0700
Message-ID: <20140808033220.GB10503@kroah.com>
References: <DC7803B42427924284F2D5252E076A3B4476A479@SINEX14MBXC416.southpacific.corp.microsoft.com>
 <53CCD6F2.6020909@nod.at> <20140721091851.GA28171@aepfle.de>
 <20140721.143225.2040366896972949930.davem@davemloft.net>
 <CAFLxGvyfy1UkxN6_-c_ST7f8n7DvqYsCPKChWmt9CerWb0dh7g@mail.gmail.com>
 <EE124450C0AAF944A40DD71E61F878C99149D0@SINEX14MBXC417.southpacific.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 Richard Weinberger <richard.weinberger@gmail.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 Haiyang Zhang <haiyangz@microsoft.com>, LKML <linux-kernel@vger.kernel.org>,
 Thomas Shao <huishao@microsoft.com>,
 "Yue Zhang \(OSTC DEV\)" <yuezha@microsoft.com>,
 David Miller <davem@davemloft.net>
To: Dexuan Cui <decui@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <EE124450C0AAF944A40DD71E61F878C99149D0@SINEX14MBXC417.southpacific.corp.microsoft.com>
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

On Fri, Aug 08, 2014 at 03:13:58AM +0000, Dexuan Cui wrote:
> > -----Original Message-----
> > From: Richard Weinberger [mailto:richard.weinberger@gmail.com]
> > Sent: Friday, August 8, 2014 6:37 AM
> > To: David Miller; Yue Zhang (OSTC DEV)
> > Cc: olaf@aepfle.de; netdev@vger.kernel.org; driverdev-
> > devel@linuxdriverproject.org; LKML; Greg KH; jasowang@redhat.com;
> > Haiyang Zhang; KY Srinivasan; Thomas Shao; Dexuan Cui
> > Subject: Re: [PATCH] Hyperv: Trigger DHCP renew after host hibernation
> > 
> > On Mon, Jul 21, 2014 at 11:32 PM, David Miller <davem@davemloft.net>
> > wrote:
> > > From: Olaf Hering <olaf@aepfle.de>
> > > Date: Mon, 21 Jul 2014 11:18:51 +0200
> > >
> > >> On Mon, Jul 21, Richard Weinberger wrote:
> > >>
> > >>> My concern is that 10 seconds is maybe not a the right choice.
> > >>> (As we cannot know all implementations)
> > >>
> > >> Until someone reports an issue with it, 10 is fine. Just like 20 or 666.
> > >
> > > Wrong, this is policy and belongs in userspace.
> > 
> > The "/etc/init.d/network restart" nonsense now hit Linus' tree.
> > Yue, what is your proposal to fix that?
> > 
> > //richard
> 
> Hi Richard and all,
> Sorry for the late response -- actually we have been trying to
> figure out a solution that's acceptable to all.
> 
> IMO the most feasible and need-the-least-change solution may be:
> the hyperv network VSC driver passes the event
> RNDIS_STATUS_NETWORK_CHANGE to the udev daemon?
> 
> In this way, every distro only needs to add a udev rule, which should
> be simple.

No, don't do that, again, act like any other network device, drop the
link and bring it up when it comes back.

greg k-h
