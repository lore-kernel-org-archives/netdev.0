From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (1/5) replay netdev notifier events on registration
Date: Wed, 14 Jan 2004 16:44:16 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040114164416.753a62fc.shemminger@osdl.org>
References: <20040113105843.0d1351cb.shemminger@osdl.org>
	<20040113163631.1a9c1a59.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, chas williams <chas@cmf.nrl.navy.mil>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040113163631.1a9c1a59.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Looks good.... are you absolutely sure no remaining notifiers will
> barf if they get a register for an already existing device?  I know up
> events should be ok...

Certainty is impossible; but here is what I saw..

Possible problems:
qeth: s390 driver -- bug, code is narcissistic and thinks it only gets
	notified about it's own devices.

atm/mpc: only looks for "lec" devices, don't know if they could exist
	before it starts.

Unrelated problems:
ddp: registers for notifier before it is initialized
ipmr: no locking for add/delete
ipfwadm: no module owner on /proc interface


The following are okay:

bonding: since must be master or slave can't exist yet
bpqether: patched, was doing replay already
ppoe: only cares about down
dlci: only cares about unregister
lapbether: patched, was doing replay already
vlan: only cares about groups that can't exist yet
aarp: only down
ddp: only cares about down 
atm/clip: see additional patch
ax25: only cares about ax25 devices can't exist yet
bridge: only cares about bridged devices can't exist yet
dst: only down
rtnetlink: ok no sockets can be open yet
decnet: see additional patch about startup order
dn_rules: looks okay
econet: only unregister
arp: only address changes
devinet: only inet devices can't exist yet
fib_frontend: looks okay happens before devices anyway
fib_rules: looks okay happens before devices anyway
ipmr: only unregister
ipqueue: only down
ipfwadm: only for chains which can't exist yet
ip6_sockglue: okay
ndisc: patched
ip6: down only
ipx: only for ipx devices which can't exist at initial
irsyms: harmless, whole notify could be removed
netrom: down only
packet: only cares about sockets which can't exist at initial
rose: down only
wanpipe: only cares about sockets which can't exist at initial
x25: only cares about x25 which can't exist yet
xfrm_policy: down only
