From: jamal <hadi@cyberus.ca>
Subject: Re: [Bonding-devel] Re: [SET 2][PATCH 2/8][bonding] Propagating
	master's  settings toslaves
Date: 11 Aug 2003 10:34:41 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1060612481.1034.15.camel@jzny.localdomain>
References: <E791C176A6139242A988ABA8B3D9B38A014C9474@hasmsx403.iil.intel.com>
	 <1060607079.1050.144.camel@jzny.localdomain>
	 <3F37A331.88EB0B1D@thalesatm.com>
	 <200308111720.38472.shmulik.hen@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Laurent DENIEL <laurent.deniel@thalesatm.com>,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
In-Reply-To: <200308111720.38472.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2003-08-11 at 10:20, Shmulik Hen wrote:
> On Monday 11 August 2003 05:07 pm, Laurent DENIEL wrote:
> > HP/Compaq/Digital used to have the same approach with their Netrain
> > implementation, and from one release of Tru64 UNIX to another, they
> > could no longer support resolution ala milli-seconds but only
> > seconds due to the move of such "richness" to user space (among
> > other things). I am not saying that doing so on Linux will result
> > to the same, but a minimal failover policy shall remain in the
> > kernel for performance reason ... (or a user space facility could
> > exist to *configure* such policy but without direct interaction
> > with user space when the kernel has to decide).
> >
> > Laurent
> 
> That was my point. Thank you for putting it into better words.
> If high availbilty and fast failovers are what's needed, why move it 
> out of kernel space and put it in an application ? How fast could it 
> work compared to a kernel module ? Why need an extra piece of code 
> running in user space (daemon?) to monitor a module when the module 
> can do that itself ?
>
> If smarter behavior is needed (e.g. falling to eth4 instead of eth1 
> when eth0 fails), we can add some priority mechanism to the driver to 
> do that when it decides to swap. Otherwise, we'll be devleoping 
> applications from now on, not the Linux kernel :)
> 

So how many smart things are you going to add to the driver? ;->
Do you wanna add the qos policy changeover as well? What about route
changes, firewalling etc. What about sliceing bread and adding butter?
Where do you draw the line?
BTW, I dont understand why it would slow down failover; sure it will a
tiny bit because you have to cross user space to lookup the policy.
Maybe this is the part that i havent made clear, heres an example:
- User space gets notified link eth0 went down
- User space looks up a policy config on what to do when eth0 goes down
- user space executes commands which may include telling kernel to 
move activity to eth1.
 
Note: I agree on a minimal failover policy staying in the kernel; very
basic stuff like what bonding used to do (may still do, dont know).

cheers,
jamal
