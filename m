From: Glen Turner <glen.turner@aarnet.edu.au>
Subject: Re: Bonding on Linux: some questions.
Date: Wed, 18 Aug 2004 22:48:06 +0930
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1092835086.3103.49.camel@andromache>
References: <4123194B.9090905@provincia.verbania.it>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Boniforti Flavio <boniforti@provincia.verbania.it>
In-Reply-To: <4123194B.9090905@provincia.verbania.it>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-08-18 at 18:24, Boniforti Flavio wrote:

> I first would like to understand some things about bonding, which I 
> can't find documented anywhere.

I found the documentation in
  /usr/src/linux-.../Documentation/networking/bonding.txt
to be very fine.

> a) Is bonding in some way dependent on the setup of the switch to which 
> I connect my Linux box? I mean: after I set up bonding on my Linux box, 
> do I also have to do some configuration on the switch? I'm asking this 
> because I read something about "trunking" in relation to bonding, but I 
> didn't get the point at all.

Different switch manufacturers using differing terminology, but
"trunking" usually refers to 802.1q or ISL VLANs.

You will usually need to do some configuration on the switch. For
example, to place the two interfaces into the same 802.3ad
"administrative group".  If you don't know the 802.3ad terminology then
the IEEE's Get802.3 program allows you to download the latest 802.3
standard and it has a perfectly readable description of 802.3ad.

For example, on a Cisco CatOS switch to bind ports 1/1 and 2/1, insist
that that want to bond, and make the switch the most trusted device for
configuration detail (rather than the host):
  set channelprotocol lacp 1 2
  set port lacp-channel 1/1 2/1
  set port lacp-channel 1/1 2/1 mode active
  set port lacp-channel 1/1 port priority 1
  set port lacp-channel 2/1 port priority 2

> b) How is the actual procedure of the bonding activation? As far as I 
> understand it, bond0 should go up, then "ifenslave" the other (two in my 
> case) ethX interfaces. The MAC address of bond0 should be the same of 
> the first slave, while the second slave gets its MAC address also set to 
> the one of the bond0 interface.

Ignore the MAC address detail. Look at /proc/net/bonding/bond0 for the
operational state.

Usually the problem is with /etc/modprobe.conf
  alias eth0 ...
  alias eth1 ...
  install bond0 modprobe bonding mode=802.3ad lacp_rate=fast miimon=100 && modprobe eth0 && modprobe eth1
You then say
  ifenslave bond0 eth0
  ifenslave bond0 eth1
  ip link set dev eth0 up
  ip link set dev eth1 up
although all this detail is usually taken care of by the network scripts
for your platform.

Note that the Fedora Core bounced the link state a few times during
setting up the bonding. This can trigger a spanning tree holddown. So
you probably also want to activate any "fast spanning tree" option and
kill any other delaying protocol negotiations (VTP, etc). To continue
the CatOS example:

  set port 1/1 2/1 host

Best of luck,
Glen

-- 
Glen Turner         Tel: (08) 8303 3936 or +61 8 8303 3936
Australian Academic & Research Network   www.aarnet.edu.au
