From: jamal <hadi@cyberus.ca>
Subject: Re: [e1000 2.6 10/11] TxDescriptors -> 1024 default
Date: 11 Sep 2003 21:34:23 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063330463.1028.8.camel@jzny.localdomain>
References: <Pine.LNX.4.44.0309081953510.1261-100000@localhost.localdomain>
	 <3F60CA6D.9090503@pobox.com>	<3F60D0F3.8080006@candelatech.com>
	 <20030911131219.0ab8dfdd.davem@redhat.com>
	 <3F60DDCC.5020906@candelatech.com>
	 <20030911140746.4f0384a1.davem@redhat.com>
	 <3F60E947.4090005@candelatech.com>
	 <20030911142906.74d9dfe5.davem@redhat.com>
	 <3F60F3F7.6090203@candelatech.com>
	 <20030911160252.6cd6c07d.davem@redhat.com>
	 <3F6103BB.5030706@candelatech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, scott.feldman@intel.com, netdev@oss.sgi.com,
   ricardoz@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F6103BB.5030706@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Scott,

dont increase the tx descriptor ring size - that would truly wasting
memory; 256 is pretty adequate.
* increase instead the txquelen (as suggested by Davem); user space
tools like ip or ifconfig could do it. The standard size has been around
100 for 100Mbps; i suppose it is fair to say that Gige can move data out
at 10x that; so set it to 1000. Maybe you can do this from the driver
based on what negotiated speed is detected?

--------
[root@jzny root]# ip link ls eth0
4: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
    link/ether 00:b0:d0:05:ae:81 brd ff:ff:ff:ff:ff:ff

[root@jzny root]# ip  link set[root@jzny root]# ip link ls eth0
4: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:b0:d0:05:ae:81 brd ff:ff:ff:ff:ff:ff eth0 txqueuelen
1000
-------

TCP already reacts on packets dropped at the scheduler level, UDP would
be too hard to enforce since the logic is typically on an app above udp.
So just conrtol it via the socket queue size.

cheers,
jamal

On Thu, 2003-09-11 at 19:22, Ben Greear wrote:
> David S. Miller wrote:
> > On Thu, 11 Sep 2003 15:15:19 -0700
> > Ben Greear <greearb@candelatech.com> wrote:
> > 
> > 
> >>And the original poster shows how a similar problem slows down TCP
> >>as well due to local dropped packets.
> > 
> > 
> > So, again, dampen the per-socket send queue sizes.
> 
> That's just a band-aid to cover up the flaw with the lack
> of queue-pressure feedback to the higher stacks, as would be increasing the
> TxDescriptors for that matter.
