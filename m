From: Pankaj Gupta <pagupta@redhat.com>
Subject: Re: [PATCH net-net 0/4] Increase the limit of tuntap queues
Date: Mon, 24 Nov 2014 09:28:25 -0500 (EST)
Message-ID: <1253769917.3166193.1416839305146.JavaMail.zimbra@redhat.com>
References: <20141123104623.GA31915@redhat.com> <20141123.134323.1154795102254868842.davem@davemloft.net> <20141123203032.GA6286@redhat.com> <20141123.202321.1426718936320546377.davem@davemloft.net> <20141124080243.GD6286@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jasowang@redhat.com, dgibson@redhat.com,
	vfalico@gmail.com, edumazet@google.com, vyasevic@redhat.com,
	hkchu@google.com, wuzhy@linux.vnet.ibm.com, xemul@parallels.com,
	therbert@google.com, bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org, jiri@resnulli.us,
	sergei shtylyov <sergei.shtylyov@cogentembedded.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141124080243.GD6286@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On Sun, Nov 23, 2014 at 08:23:21PM -0500, David Miller wrote:
> > From: "Michael S. Tsirkin" <mst@redhat.com>
> > Date: Sun, 23 Nov 2014 22:30:32 +0200
> > 
> > > qemu runs in the host, but it's unpriveledged: it gets
> > > passed tun FDs by a priveledged daemon, and it only
> > > has the rights to some operations,
> > > in particular to attach and detach queues.
> > > 
> > > The assumption always was that this operation is safe
> > > and can't make kernel run out of resources.
> > 
> > This creates a rather rediculous situation in my opinion.
> > 
> > Configuring a network device is a privileged operation, the daemon
> > should be setting this thing up.
> > 
> > In no other context would we have to worry about something like this.
> 
> Right.  Jason corrected me.  I got it wrong:
> what qemu does is TUNSETQUEUE and that needs to get a queue
> that's already initialized by the daemon.
> 
> To create new queues daemon calls TUNSETIFF,
> and that already can be used to create new devices,
> so it's a priveledged operation.
> 
> This means it's safe to just drop the restriction,
> exactly as you suggested originally.

I will drop patch2 to add sysctl entry and and will send a v2 with other 
patches.

Thanks,
Pankaj

> --
> MST
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
