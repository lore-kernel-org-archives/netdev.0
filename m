From: jamal <hadi@cyberus.ca>
Subject: Re: ifconfig TX/RX errors
Date: Mon, 18 Nov 2002 21:12:01 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0211182054200.14587-100000@shell.cyberus.ca>
References: <Pine.LNX.4.44.0211131127510.1024-100000@beohost.scyld.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
In-Reply-To: <Pine.LNX.4.44.0211131127510.1024-100000@beohost.scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Wed, 13 Nov 2002, Donald Becker wrote:

> Are you certain about that Jamal?  This is /proc/net/dev numbers
> covering the network interface device layer, not the protocol layers,
> The numbers Linux 'ifconfig' reports are similar, but not the same as
> the very limited counts that the old BSDs used.
>

Heres output of ifconfig

------------------------------
eth0      Link encap:Ethernet  HWaddr 00:02:B3:2B:CD:A4
          inet addr:10.0.0.10  Bcast:10.0.0.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:87445 errors:0 dropped:0 overruns:0 frame:0
          TX packets:29162 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100
          Interrupt:5

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:7137 errors:0 dropped:0 overruns:0 frame:0
          TX packets:7137 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
-----------------------------

I start ucd snmpd and walk .1.3.6.1.2.1.2 which is the ifentry
section of the interfaces table.

-------------
interfaces.ifNumber.0 = 2
interfaces.ifTable.ifEntry.ifIndex.1 = 1
interfaces.ifTable.ifEntry.ifIndex.2 = 2
interfaces.ifTable.ifEntry.ifDescr.1 = lo0
interfaces.ifTable.ifEntry.ifDescr.2 = eth0
interfaces.ifTable.ifEntry.ifType.1 = softwareLoopback(24)
interfaces.ifTable.ifEntry.ifType.2 = ethernetCsmacd(6)
interfaces.ifTable.ifEntry.ifMtu.1 = 16436
interfaces.ifTable.ifEntry.ifMtu.2 = 1500
interfaces.ifTable.ifEntry.ifSpeed.1 = Gauge: 10000000
interfaces.ifTable.ifEntry.ifSpeed.2 = Gauge: 10000000
interfaces.ifTable.ifEntry.ifPhysAddress.1 =
interfaces.ifTable.ifEntry.ifPhysAddress.2 = 0:2:b3:2b:cd:a4
interfaces.ifTable.ifEntry.ifAdminStatus.1 = up(1)
interfaces.ifTable.ifEntry.ifAdminStatus.2 = up(1)
interfaces.ifTable.ifEntry.ifOperStatus.1 = up(1)
interfaces.ifTable.ifEntry.ifOperStatus.2 = up(1)
interfaces.ifTable.ifEntry.ifInOctets.1 = 637875
interfaces.ifTable.ifEntry.ifInOctets.2 = 28723267
interfaces.ifTable.ifEntry.ifInUcastPkts.1 = 7176
interfaces.ifTable.ifEntry.ifInUcastPkts.2 = 87445
interfaces.ifTable.ifEntry.ifInErrors.1 = 0
interfaces.ifTable.ifEntry.ifInErrors.2 = 0
interfaces.ifTable.ifEntry.ifOutOctets.1 = 638861
interfaces.ifTable.ifEntry.ifOutOctets.2 = 2506626
interfaces.ifTable.ifEntry.ifOutUcastPkts.1 = 7188
interfaces.ifTable.ifEntry.ifOutUcastPkts.2 = 29162
interfaces.ifTable.ifEntry.ifOutDiscards.1 = 0
interfaces.ifTable.ifEntry.ifOutDiscards.2 = 0
interfaces.ifTable.ifEntry.ifOutErrors.1 = 0
interfaces.ifTable.ifEntry.ifOutErrors.2 = 0
interfaces.ifTable.ifEntry.ifOutQLen.1 = Gauge: 0
interfaces.ifTable.ifEntry.ifOutQLen.2 = Gauge: 0
interfaces.ifTable.ifEntry.ifSpecific.1 = OID: .ccitt.nullOID
interfaces.ifTable.ifEntry.ifSpecific.2 = OID: .ccitt.nullOID
---------------------

Although i dont have the ifOutErrors for example with any values,
my observation is they match the ifconfig or netstat or ip outputs.
Cross referencing with the RFC seems to match the semantics as well.
Actually i believe ucd snmp reads the proc/net/dev output but i havent
looked at the code. So maybe when you added those entries back then
they were already being used for snmp by the BSDs?

> When I wrote the /proc/net/dev statistics count output, I unwisely
> summarized some of the independent fields the drivers recorded to fit
> into an 79 column output(1).  I should have output all of the
> statistics, and let user-level programs summarize as they saw fit.
> Even today there is no way to get out the individual numbers.
>

if you dont care about readability, probably a hex output would go a long
way. eg /proc/net/softnet_stat does this to fit things

> (1) That effort at human readability was discarded when new fields
> were added, making the output incompatible with earlier versions of
> ifconfig.  So now the output is longer than a line, but it still
> doesn't break out the important error counts.

I am not well versed with the history; are there any stats that
you would like to see that are missing?

cheers,
jamal
