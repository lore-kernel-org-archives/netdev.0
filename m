From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Re: [Bonding-devel] Re: [SET 2][PATCH 2/8][bonding] Propagating master's  settings toslaves
Date: Mon, 11 Aug 2003 19:25:38 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308111925.38278.shmulik.hen@intel.com>
References: <E791C176A6139242A988ABA8B3D9B38A014C9474@hasmsx403.iil.intel.com> <200308111720.38472.shmulik.hen@intel.com> <1060612481.1034.15.camel@jzny.localdomain>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Laurent DENIEL <laurent.deniel@thalesatm.com>,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1060612481.1034.15.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 11 August 2003 05:34 pm, jamal wrote:
> So how many smart things are you going to add to the driver? ;->
> Do you wanna add the qos policy changeover as well? What about
> route changes, firewalling etc. What about sliceing bread and
> adding butter? Where do you draw the line?
> BTW, I dont understand why it would slow down failover; sure it
> will a tiny bit because you have to cross user space to lookup the
> policy. Maybe this is the part that i havent made clear, heres an
> example: - User space gets notified link eth0 went down
> - User space looks up a policy config on what to do when eth0 goes
> down - user space executes commands which may include telling
> kernel to move activity to eth1.
>
> Note: I agree on a minimal failover policy staying in the kernel;
> very basic stuff like what bonding used to do (may still do, dont
> know).
>
> cheers,
> jamal

Why have any kernel code other than device drivers in the first place 
?
Why not move all the TCP/IP stack out of kernel space and put it in an 
application ? Lets have the entire ARP mechanism in an appliaction 
and let it handle everything from routing tables management to arp 
negotiation while the kernel will only know how to create arp packets 
that it gets from that app and send them away ? It doesn't need to 
have the know how.
Say we do thing s your way and use the notification mechanism, how 
long do you think it's going to take for the whole operation to 
finish taking into consideration how the kernel runs user space 
applications in comparison with kernel code? what happens when the 
system is heavily loaded ? What happens if the application dies for 
some reason ? 
Why should the bonding driver even care about routes or firewalling ?
It's only meant to group several physical ethernet devices and group 
them under one logical device to handle teaming solutions.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
