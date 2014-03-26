From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [RFC 1/2] pm: Introduce QoS requests per CPU
Date: Wed, 26 Mar 2014 17:40:15 +0200
Message-ID: <5332F4DF.2030106@mellanox.com>
References: <1395753505-13180-1-git-send-email-amirv@mellanox.com> <1395753505-13180-2-git-send-email-amirv@mellanox.com> <2896374.SoOPVJXu9Q@vostro.rjw.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	<linux-pm@vger.kernel.org>, <netdev@vger.kernel.org>,
	Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>,
	<yuvali@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>, <idos@mellanox.com>,
	<hadarh@mellanox.com>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <2896374.SoOPVJXu9Q@vostro.rjw.lan>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[This mail might be double posted due to problems I have with the mail 
server]

On 25/03/14 19:44 +0100, Rafael J. Wysocki wrote:
> On Tuesday, March 25, 2014 03:18:24 PM Amir Vadai wrote:
> > Extend the current pm_qos_request API - to have pm_qos_request per core.
> > When a global request is added, it is added under the global plist.
> > When a core specific request is added, it is added to the core specific
> > list.
> > core number is saved in the request and later modify/delete operations
> > are using it to access the right list.
> >
> > When a cpu specific request is added/removed/updated, the target value
> > of the specific core is recalculated to be the min/max (according to the
> > constrain type) value of all the global and the cpu specific
> > constraints.
> >
> > If a global request is added/removed/updated, the target values of all
> > the cpu's are recalculated.
> >
> > During initialization, before the cpu specific data structures are
> > allocated and initialized, only global target value is begin used.
>
> I have to review this in detail (which rather won't be possible before
> the next week), but in principle I don't really like it, because it
> assumes that its users will know what's going to run on which CPU cores
> and I'm not sure where that knowledge is going to come from.
>

The network driver can use affinity hint and irq balancer to set the
affinity of IRQ (and rx ring) to a core. A stream is tied to an rx
ring by RSS/Flow steering. So, if we have an active flow, we can know
which CPU will be used.
The feature could be turned off by default and be used only when the
driver has all the needed information.

Thank you for your time,
Amir
