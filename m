From: Ben Greear <greearb@candelatech.com>
Subject: Re: ARP problem?
Date: Wed, 16 Oct 2002 16:06:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DADF10B.3080804@candelatech.com>
References: <E156A23F1885D4119ED800B0D0498A9F02128B94@aimexc07.adaptec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Thompson, Ian" <Ian_Thompson@adaptec.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thompson, Ian wrote:
> Hi,
> 
> I'm seeing some odd behavior in RedHat 7.3 when handling ARP packets.  I
> have two Intel NIC cards, eth0 and eth1, in one machine, connected to the
> same switch.  eth0 is set to IP0 and has MAC addr M0, and eth1 is at IP1 and
> MAC M1.  Now, if another machine connected to the switch sends an ARP
> broadcast asking who is at IP0, I see two replies on the wire -- IP0 is at
> M0, and IP0 is at M1.  This result seems contradictory to me; could it be
> some sort of feature that I'm not aware of?  If so, can I disable it?
> 
> I am trying to devlop some code to support an active failover case, so I
> want two seperate devices on the same physical network.  I have seen the
> same result even if IP0 and IP1 are on different subnets, or even if one is
> a class A and the other is a class C address.  
> 
> I'm sorry if this has already been discussed -- I haven't seen much relating
> to it in the archives.

You need arp-filtering:

     # Set up arp-filter magic.  This, with source-based routing allows us
     # to have multiple NICs on the same subnet, on the same machine, connected
     # to the same switch...
     if [ -f  /proc/sys/net/ipv4/conf/all/arp_filter ];
     then
	echo 1 > /proc/sys/net/ipv4/conf/all/arp_filter
     else
	echo "ERROR: kernel does not support arp_filter.  Don't put more than"
	echo "       one interface on the same subnet on the same machine."
	echo ""
     fi


> 
> TIA,
> -ian
> 
> ---
> Ian Thompson               Firmware Engineer
> Adaptec, Inc               Storage Networking Group
> 408.957.4909               408.957.6800 (fax)
> ian_thompson@adaptec.com
> 
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
