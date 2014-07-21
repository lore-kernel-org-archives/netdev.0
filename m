From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] Hyperv: Trigger DHCP renew after host hibernation
Date: Mon, 21 Jul 2014 12:17:36 -0500
Message-ID: <1405963056.20886.9.camel@dcbw.local>
References: <1405680903-28176-1-git-send-email-yuezha@microsoft.com>
 <CAG-2HqXFBUmpTAE8h13-DmP6Fq42viHzmuH9OfNoLgjW8XcQ3Q@mail.gmail.com>
 <DC7803B42427924284F2D5252E076A3B4476A6D1@SINEX14MBXC416.southpacific.corp.microsoft.com>
 <20140721131154.GA23385@tango.0pointer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>, netdev <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 Haiyang Zhang <haiyangz@microsoft.com>, LKML <linux-kernel@vger.kernel.org>,
 Tom Gundersen <teg@jklm.no>, "Yue Zhang \(OSTC DEV\)" <yuezha@microsoft.com>,
 Greg KH <gregkh@linuxfoundation.org>, Thomas Shao <huishao@microsoft.com>,
 David Miller <davem@davemloft.net>
To: Lennart Poettering <mzxreary@0pointer.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140721131154.GA23385@tango.0pointer.de>
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

On Mon, 2014-07-21 at 15:11 +0200, Lennart Poettering wrote:
> On Mon, 21.07.14 10:21, Yue Zhang (OSTC DEV) (yuezha@microsoft.com) wrote:
> 
> > Some network monitoring daemon, like ifplugd has a deferring mechanism.
> > When it detects carriers is offline, it doesn't trigger DHCP renew immediately. 
> > Instead it will wait for another 5 seconds to check whether carrier is back to 
> > online status. In that case, it will avoid renew DHCP lease.
> 
> ifplugd doesn't renew DHCP leases anyway, one of the scripts it invokes
> does.
> 
> ifplugd is obsolete software. I wrote it more than 10 years ago, and
> haven't really updated it since. it's sounds seriously wrong to add
> multi-second waits to the kernel just to make this crappy, obsolete
> software work.
> 
> Please fix this properly, and work with the PM guys, so that we get a
> sane userspace how the kernel can notify userspace about
> suspends/hibernations triggered from the outside, so that userspace
> daemons can subscribe to that and then refresh the DHCP leases on their
> own.

Yeah, like I've said before, there have been other cases where a "hey,
my L3 address might be wrong now, so please confirm it" message would be
useful.  Carrier on/off doesn't necessarily mean that, but even if it
did, the off interval is a really bad mechanism for that too.  So I'd
really like some kind of event for this that's distinct from carrier
that userspace could use.

Dan
