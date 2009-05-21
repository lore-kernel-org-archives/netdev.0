From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH] ieee1394: eth1394: use "firewire%d" instead of "eth%d"
	as interface name
Date: Thu, 21 May 2009 16:31:18 +0200
Message-ID: <4A1565B6.10907@s5r6.in-berlin.de>
References: <tkrat.21c425cc195510c9@s5r6.in-berlin.de>
	<20090521134856.GA3457@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Fenlason <fenlason@redhat.com>,
	linux1394-devel@lists.sourceforge.net,
	linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20090521134856.GA3457@psychotron.englab.brq.redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Jiri Pirko wrote:
> Thu, May 21, 2009 at 03:29:10PM CEST, stefanr@s5r6.in-berlin.de wrote:
>> -	dev = alloc_netdev(sizeof(*priv), "eth%d", ether1394_init_dev);
>> +	dev = alloc_netdev(sizeof(*priv),
>> +			   firewire_interface_name ? "firewire%d" : "eth%d",
> 
> Isn't "firewire" too long? Wouldn't it be better to use some addrev like other
> devices do? "fw"? To safe some time and possible troubles with typos.
> 
> Just a thought.

Usually I prefer brevity too.  Alas, it may not be clear to many people 
what "fw" is supposed to mean.  People might associate it with, let's 
say, "firewall" before "firewire" when they deal with networking. 
However, more opinions on this are welcome.

As for practical length restrictions:  The kernel's networking core 
requires that these names fit into 15 characters plus trailing \0.  I 
don't have an idea whether there are userland components which have even 
tighter restrictions.

Does anybody know of potential trouble in networking tools if interface 
names are 9 or 10 characters long?

BTW, FreeBSD uses the name fwip%d AFAIK, and OS X just uses fw%d.  (But 
basically nobody is ever confronted with this interface name on OS X 
because Apple's network config GUIs don't use them.)

FWIW, ifconfig's output is still nicely aligned after this change. :-)

-------------------- 8< --------------------

eth0      Link encap:Ethernet  HWaddr 00:23:54:91:8a:2b
           inet addr:192.168.0.42  Bcast:192.168.0.255  Mask:255.255.255.0
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:12350891 errors:0 dropped:0 overruns:0 frame:0
           TX packets:13934958 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:7376420576 (6.8 GiB)  TX bytes:8066580858 (7.5 GiB)
           Interrupt:28 Base address:0xa000

firewire0 Link encap:UNSPEC  HWaddr 
08-00-28-56-00-00-31-9B-00-00-00-00-00-00-00-00
           inet addr:10.10.222.42  Bcast:10.10.222.255  Mask:255.255.255.0
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:2 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:0 (0.0 B)  TX bytes:72 (72.0 B)

lo        Link encap:Local Loopback
           inet addr:127.0.0.1  Mask:255.0.0.0
           UP LOOPBACK RUNNING  MTU:16436  Metric:1
           RX packets:2865 errors:0 dropped:0 overruns:0 frame:0
           TX packets:2865 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:1292569 (1.2 MiB)  TX bytes:1292569 (1.2 MiB)
-- 
Stefan Richter
-=====-=-=== -=-= -==-=
http://arcgraph.de/sr/

------------------------------------------------------------------------------
Register Now for Creativity and Technology (CaT), June 3rd, NYC. CaT
is a gathering of tech-side developers & brand creativity professionals. Meet
the minds behind Google Creative Lab, Visual Complexity, Processing, & 
iPhoneDevCamp asthey present alongside digital heavyweights like Barbarian
Group, R/GA, & Big Spaceship. http://www.creativitycat.com 
