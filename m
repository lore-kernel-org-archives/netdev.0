From: "Hen, Shmulik" <shmulik.hen@intel.com>
Subject: RE: [SET 2][PATCH 2/8][bonding] Propagating master's settings to slaves
Date: Sat, 9 Aug 2003 13:29:08 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E791C176A6139242A988ABA8B3D9B38A014C9474@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: jamal [mailto:hadi@cyberus.ca]
> Sent: Saturday, August 09, 2003 1:01 AM
> To: Hen, Shmulik
> Cc: bonding-devel@lists.sourceforge.net; netdev@oss.sgi.com
> Subject: Re: [SET 2][PATCH 2/8][bonding] Propagating master's settings
> to slaves
> 
> Shmulik,
> 
> Some of this bonding stuff is pretty scary. Lotsa policies in the 
> kernel and communication seems to be centred around /proc.
> Shouldnt policies on failover be really driven from user space?
> Also shouldnt communication be using something like netlink?
> 
> cheers,
> jamal
> 
> On Fri, 2003-08-08 at 10:44, Shmulik Hen wrote:
> > 2 - Change monitoring function use the new functionality.
> > 
> 

Not sure I fully understood the concerns above, but I'll try
to explain what the change was all about.

By monitoring, I meant the 3 timer function running in bonding
to monitor link changes and act once a link fail/recovery is
detected. The old code used to do all the activity related to
changing the current active slave separately in each timer
function and it seemed redundant since it was basically the
same thing repeated 3 times. Instead, we thought it would be
best if we put that into 3 new functions - reselect_active,
find_best_slave and change_active that does all the actual stuff
of swapping an old current with the new one.

The change we did in /proc was to reduce the amount of data
extarcted each time the proc entry is polled. Instead of dumping
all the data of all the bond devices that exist, each bond returns
just data that is relevant to itself.

In the lonf term, the drive is to move any *smart* code done in
the config application into the driver itself and be left with
the smallest, most compact application as possible. This is the
trend we've seen in the VLAN config app, and the bridge module.
All the "brain" is in the kernel module and very little should be
done in the application.


	Shmulik.
