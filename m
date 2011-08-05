From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [forcedeth bug] Re: [GIT] Networking
Date: Fri, 5 Aug 2011 13:25:58 +0200
Message-ID: <20110805112557.GD1928@minipsycho.orion>
References: <20110722.073339.1236244143490935644.davem@davemloft.net>
 <20110801151308.GA31256@elte.hu>
 <20110804215354.GA7056@elte.hu>
 <20110805102239.GB1928@minipsycho.orion>
 <20110805102903.GF2420@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110805102903.GF2420@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fri, Aug 05, 2011 at 12:29:03PM CEST, mingo@elte.hu wrote:
>
>* Jiri Pirko <jpirko@redhat.com> wrote:
>
>> Thu, Aug 04, 2011 at 11:53:54PM CEST, mingo@elte.hu wrote:
>> >
>> >* Ingo Molnar <mingo@elte.hu> wrote:
>> >
>> >>  0891b0e08937: forcedeth: fix vlans
>> >
>> >Hm, forcedeth is still giving me trouble even on latest -git that has 
>> >the above fix included.
>> >
>> >The symptom is a stuck interface, no packets in. There's a frame 
>> >error RX packet:
>> >
>> > [root@mercury ~]# ifconfig eth0
>> > eth0      Link encap:Ethernet  HWaddr 00:13:D4:DC:41:12  
>> >           inet addr:10.0.1.13  Bcast:10.0.1.255  Mask:255.255.255.0
>> >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>> >           RX packets:0 errors:1 dropped:0 overruns:0 frame:1
>> >           TX packets:531 errors:0 dropped:0 overruns:0 carrier:0
>> >           collisions:0 txqueuelen:1000 
>> >           RX bytes:0 (0.0 b)  TX bytes:34112 (33.3 KiB)
>> >           Interrupt:35 
>> >
>> >Weirdly enough a defconfig x86 bootup works just fine - it's certain 
>> >.config combinations that trigger the bug. I've attached such a 
>> >config.
>> >
>> >Note that at least once i've observed a seemingly good kernel going 
>> >'bad' after a couple of minutes uptime. I've also observed 
>> >intermittent behavior - apparent lost packets and a laggy network.
>> >
>> >I have done 3 failed attempts to bisect it any further - i got to the 
>> >commit that got fixed by:
>> >
>> >  0891b0e08937: forcedeth: fix vlans
>> >
>> >... but that's something we already knew.
>> >
>> >Let me know if there's any data i can provide to help debug this 
>> >problem.
>> >
>> >Thanks,
>> >
>> >	Ingo
>> 
>> Interesting.
>> 
>> Is DEV_HAS_VLAN set in id->driver_data (L5344) ?
>
>How do i tell that without hacking the driver?

look in dmesg for line like:
"forcedeth 0000:00:08.0: highdma csum vlan pwrctl mgmt gbit lnktim msi
desc-v3"

if "vlan" is there, DEV_HAS_VLAN is set

>
>> If so, would you try to disable both rx an tx vlan accel using 
>> ethtool and see if it helps?
>
>Should i do that when the device is in a stuck state and see whether 
>it recovers?

Yes.

>
>Also, please provide the exact ethtool command sequences i should 
>try, this makes it easier for me to test exactly what you want me to 
>test.

ethtool -K eth0 txvlan off rxvlan off


>
>Thanks,
>
>	Ingo
