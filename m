From: bert hubert <ahu@ds9a.nl>
Subject: (udp-en/decap broken in 2.6.8-rc2?) Re: ipsec, nat-t, iproute2?
Date: Sat, 31 Jul 2004 00:38:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040730223808.GA12660@outpost.ds9a.nl>
References: <20040730170726.GA5144@outpost.ds9a.nl> <Xine.LNX.4.44.0407301453470.20521-100000@dhcp83-76.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0407301453470.20521-100000@dhcp83-76.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 30, 2004 at 02:55:19PM -0400, James Morris wrote:

> PF_KEY is not deprecated, it's an IETF standard and required for
> compliance & compatibility.  XFRM_USER is simply the native Linux
> interface.

Ok, thanks. I've gotten to the point where I can configure nat-t over XFRM,
however, I find that it does not work.

The encoding looks fine but the receiving side does not appear to listen:

00:34:09.491228 IP 192.168.1.4.4500 > 10.0.0.3.4500: UDP, length: 88
00:34:09.492290 IP 10.0.0.3 > 192.168.1.4: icmp 124: 10.0.0.3 udp port 4500
	unreachable
00:34:10.492245 IP 192.168.1.4.4500 > 10.0.0.3.4500: UDP, length: 88
00:34:10.493332 IP 10.0.0.3 > 192.168.1.4: icmp 124: 10.0.0.3 udp port 4500
	unreachable
00:34:11.493090 IP 192.168.1.4.4500 > 10.0.0.3.4500: UDP, length: 88
00:34:11.494337 IP 10.0.0.3 > 192.168.1.4: icmp 124: 10.0.0.3 udp port 4500
	unreachable

This is the setkey configuration I use on 10.0.0.3:

#!/usr/sbin/setkey -f
flush;
spdflush;

add 192.168.1.4 10.0.0.3 esp-udp 10.0.0.3 34501
	-E 3des-cbc "123456789012123456789012";

spdadd 192.168.1.4 10.0.0.3 icmp -P in ipsec
           esp/transport//require;

And on the other side (192.168.1.4):

#!/usr/sbin/setkey -f
flush;
spdflush;

add 192.168.1.4 10.0.0.3 esp-udp 192.168.1.4 34501
	-E 3des-cbc "123456789012123456789012";

spdadd 192.168.1.4 10.0.0.3 icmp -P out ipsec
           esp/transport//require;


I've toyed a bit with the IP address after esp-udp, not sure what it does.

Thanks.

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
