From: Valentijn Sessink <netdev1080549435@mail.v.sessink.nl>
Subject: IPsec 2.6 fragmentation issue(s)
Date: Mon, 29 Mar 2004 10:37:38 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040329083738.GA14167@openoffice.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux networking <netdev@oss.sgi.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello list,

I'm having various problems with 2.6 native IPsec and fragmentation. Most
notably, the following - between host valentijn (2.6.1) and host21 there's a
Wifi IPsec tunnel:

  valentijn:~# ping -s 1435 host21
  PING host21.wireless.palmgracht.nl (10.15.67.21): 1435 data bytes
  ping: sendto: Message too long
  ping: wrote host21.wireless.palmgracht.nl 1443 chars, ret=-1
  ping: sendto: Message too long
  ping: wrote host21.wireless.palmgracht.nl 1443 chars, ret=-1

Resetting the MTU on the network interface helps:

  valentijn:~# ifconfig eth1 mtu 1400
  valentijn:~# ping -s 1417 host21
  PING host21.wireless.palmgracht.nl (10.15.67.21): 1417 data bytes
  1425 bytes from 10.15.67.21: icmp_seq=0 ttl=64 time=93.0 ms
  1425 bytes from 10.15.67.21: icmp_seq=1 ttl=64 time=78.2 ms

Then, resetting it to 1500 again does this:
valentijn:~# ifconfig eth1 mtu 1500
valentijn:~# ping -s 1435 host21
  PING host21.wireless.palmgracht.nl (10.15.67.21): 1435 data bytes
  ping: sendto: Message too long
  ping: wrote host21.wireless.palmgracht.nl 1443 chars, ret=-1
  1443 bytes from 10.15.67.21: icmp_seq=1 ttl=64 time=89.0 ms
  1443 bytes from 10.15.67.21: icmp_seq=2 ttl=64 time=79.9 ms

These MTU difficulties seem to propagate to a whole set of tunneling
difficulties, none of them clear enough to mention here, as my other side is
still a 2.4.24-with-IPsec backport.

Best regards,

Valentijn
-- 
http://www.openoffice.nl/   Open Office - Linux Office Solutions
Valentijn Sessink  valentyn+sessink@nospam.openoffice.nl
