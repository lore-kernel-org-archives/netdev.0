From: Michal Ludvig <mludvig@suse.cz>
Subject: Re: 2.6.2 issues (IPSec+NAT, RFC2684 bridge)
Date: Tue, 24 Feb 2004 11:23:25 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <403B261D.90000@suse.cz>
References: <66187D861C1747499BE1365B74E036917B5F82@mdant.atkin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Samofatov, Nickolay" <Nickolay@BroadViewSoftware.com>
In-Reply-To: <66187D861C1747499BE1365B74E036917B5F82@mdant.atkin.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Samofatov, Nickolay told me that:
> Here is a list of minor issues I encountered when migrated my AMD64
> machine to 2.6.2 kernel (64-bit).
> 
> 1) Attempts to combine IPSec and NAT result in various kinds of
> failures. The easiest to reproduce is reliable hard system lock-up when
> IKE session needs to be initiated because of request from masqueraded
> machine.
> (workaround is to run cron job keeping IPSec connection active)

You probably hit the same bug as I did. When a SPD policy expires the 
notification to userspace fails. Please try the patch from here and let 
me know if it helps:
http://marc.theaimsgroup.com/?l=linux-netdev&m=107761652405761&w=2

> 2) I had to add following line to my routing rules to get IPSec working
> locally:
> --
> route add -m 172.20.0.0 netmask 255.255.0.0 gw 172.21.113.1
> --
> 172.20.0.0 here is VPN subnet I'm interested in. 172.21.113.1 is the
> address assigned to eth0 interface which is also IP address of this
> machine in VPN.
> Before I added this rule TCP connections from localhost failed with no
> route to host. The result works for most applications, but not all. For
> example, SSH fails.
> (my workaround is to use SOCKS5 proxy running locally for local SSH
> connections over IPSec tunnels)

Try to specify source address as well:
ip route add 172.20.0.0/16 via 172.21.113.1 src 172.21.x.x

> If there is interest, I may provide as much information as required to
> resolve the problems.

If the IPsec issues still remain, send me more information so that I 
could reproduce it here.

Michal Ludvig
-- 
SUSE Labs                    mludvig@suse.cz | Cray is the only computer
(+420) 296.545.373        http://www.suse.cz | that runs an endless loop
Personal homepage http://www.logix.cz/michal | in just four hours.
