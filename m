From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: sis900: eth0: NULL pointer encountered in Rx ring, skipping
Date: Tue, 18 Jan 2005 11:13:58 +0100
Message-ID: <20050118101358.GA9335@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I can make one of my machines, which has an on-board sis900 NIC, lose
network connectivity within seconds by doing something like
"nc -l -p 6666 > /dev/null" and then blasting some data towards it.  When
this happens, syslog fills up with these messages:

	eth0: NULL pointer encountered in Rx ring, skipping

It seems like the driver+NIC combo doesn't handle any kind of load very
well in general -- whenever it receives more than just a few tens of
packets per second, the machine's ping time turns rather awful:  (Two
machines on 100Mb/s with an el-cheapo 8-port 100Mb/s switch between
them.  Other machines on the same switch don't show any of the same
problems.)

	64 bytes from 10.0.0.4: icmp_seq=212 ttl=64 time=128 ms
	64 bytes from 10.0.0.4: icmp_seq=213 ttl=64 time=124 ms
	64 bytes from 10.0.0.4: icmp_seq=214 ttl=64 time=119 ms
	64 bytes from 10.0.0.4: icmp_seq=215 ttl=64 time=124 ms

When it locks up, 'ifconfig eth0 down up' suffices to make it come back
to life.  I haven't checked whether it's just RX that stops working or
whether it's both RX and TX.

Any ideas?  This is on the Fedora Core 3 update kernel, 2.6.10-based.


cheers,
Lennert
