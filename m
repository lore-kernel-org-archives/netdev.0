From: Andre Tomt <andre@tomt.net>
Subject: Re: unregister_netdevice: waiting for tun6to4 to become free.
Date: Thu, 23 Sep 2004 09:13:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41527796.4010204@tomt.net>
References: <20040920212453.GA15392@ee.oulu.fi> <414F7CD9.3090008@pobox.com> <414FC92F.6090009@tomt.net> <20040921121332.GR31616@rei.reeler.org> <4151E680.80203@tomt.net> <20040922211942.GA1674@postel.suug.ch> <41523670.1090603@tomt.net> <41523EC5.20805@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <41523EC5.20805@tomt.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(CC'ed to netdev)

<snip>

I can taste the bug now :-)

Me and Thomas Graf have been discussing this a bit off-list; so for 
those on netdev, this is my current setup:

server A sets up a sit tunnel to server B. server B has a sit tunnel to 
Provider. All communication between A, B and Provider is going over 
ethernet on the physical layer.

server B is the one getting stuck in "waiting for <device> to become 
free.." when ifdown'ing (ip tunnel del) the interface to Provider.


If I boot with net.ipv6.conf.default.forward = 1 in sysctl.conf - but 
then after the boot do echo 1 > /proc/sys/net/ipv6/conf/all/forward (to 
actually get it running)

we'll crash and burn when taking down the interface.

Only setting /proc/sys/net/ipv6/conf/all/forward = 1, but never touch 
default, it goes down cleanly.

I have the ipv6/conf/default/forwarding set in sysctl.conf on all the 
routers, and it seems zebra sets the ipv6/conf/all/forwarding later on.
