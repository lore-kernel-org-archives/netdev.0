From: jamal <hadi@cyberus.ca>
Subject: Re: ing_filter debug messages
Date: 31 Dec 2004 06:11:51 -0500
Message-ID: <1104491510.1047.234.camel@jzny.localdomain>
References: <20041230160643.GD24603@wiggy.net>
	 <1104469666.1049.231.camel@jzny.localdomain>
	 <20041231093827.GG24603@wiggy.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-x0GzCbij3ytyMxBNNDtZ"
Cc: netdev@oss.sgi.com, tgraf@suug.ch
Return-path: <netdev-bounce@oss.sgi.com>
To: Wichert Akkerman <wichert@wiggy.net>
In-Reply-To: <20041231093827.GG24603@wiggy.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-x0GzCbij3ytyMxBNNDtZ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

The sit tunnel is on top of eth1?
Does attached patch fix it?

cheers,
jamal

On Fri, 2004-12-31 at 04:38, Wichert Akkerman wrote:
> Previously jamal wrote:
> > The emssage is useful but debug (mostly). 
> > Whats your ifconfig look like? Have some tunnels in there maybe?
> 
> three ethernet interfaces and a ipv6/ip tunnel. Here is the ifconfig
> output:
> 
> eth0      Link encap:Ethernet  HWaddr 00:50:04:0B:DD:79
>           inet addr:192.168.10.1  Bcast:192.168.10.255  Mask:255.255.255.0
>           inet6 addr: fe80::250:4ff:fe0b:dd79/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:673540 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:668357 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:229549898 (218.9 MiB)  TX bytes:465650601 (444.0 MiB)
>           Interrupt:11 Base address:0xec00
> 
> eth1      Link encap:Ethernet  HWaddr 00:90:27:BE:60:55
>           inet addr:194.109.254.66  Bcast:255.255.255.255  Mask:255.255.255.0
>           inet6 addr: fe80::290:27ff:febe:6055/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:1276385 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:1172898 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:1128 txqueuelen:1000
>           RX bytes:1332651102 (1.2 GiB)  TX bytes:293617934 (280.0 MiB)
> 
> eth2      Link encap:Ethernet  HWaddr 00:90:27:BE:4B:EC
>           inet addr:192.168.1.1  Bcast:192.168.1.255  Mask:255.255.255.0
>           inet6 addr: 2001:888:101d::1/64 Scope:Global
>           inet6 addr: fe80::290:27ff:febe:4bec/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:713928 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:752929 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:111560554 (106.3 MiB)  TX bytes:860040830 (820.1 MiB)
> 
> lo        Link encap:Local Loopback
>           inet addr:127.0.0.1  Mask:255.0.0.0
>           inet6 addr: ::1/128 Scope:Host
>           UP LOOPBACK RUNNING  MTU:16436  Metric:1
>           RX packets:33261 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:33261 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:3401641 (3.2 MiB)  TX bytes:3401641 (3.2 MiB)
> 
> xs4all    Link encap:IPv6-in-IPv4
>           inet6 addr: 2001:888:10:1d::2/64 Scope:Global
>           inet6 addr: fe80::c26d:fe42/64 Scope:Link
>           inet6 addr: fe80::c0a8:a01/64 Scope:Link
>           inet6 addr: fe80::c0a8:102/64 Scope:Link
>           inet6 addr: fe80::c0a8:101/64 Scope:Link
>           UP POINTOPOINT RUNNING NOARP  MTU:1480  Metric:1
>           RX packets:128 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:116 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:95545 (93.3 KiB)  TX bytes:19613 (19.1 KiB)
> 
> there is also a secondary address on eth2 which ifconfig does not show.
> 
> > Whats your netfilter setup? 
> 
> One chain attached to the FORWARD chain and two to the OUTPUT chain,
> all pretty simple.
> 
> Wichert.

--=-x0GzCbij3ytyMxBNNDtZ
Content-Disposition: attachment; filename=sit-p
Content-Type: text/plain; name=sit-p; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/net/ipv6/sit.c	2004/12/31 11:03:32	1.1
+++ b/net/ipv6/sit.c	2004/12/31 11:06:50
@@ -385,7 +385,7 @@
 		skb->pkt_type = PACKET_HOST;
 		tunnel->stat.rx_packets++;
 		tunnel->stat.rx_bytes += skb->len;
-		skb->dev = tunnel->dev;
+		skb->input_dev = skb->dev = tunnel->dev;
 		dst_release(skb->dst);
 		skb->dst = NULL;
 		nf_reset(skb);

--=-x0GzCbij3ytyMxBNNDtZ--
