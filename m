From: jamal <hadi@cyberus.ca>
Subject: Re: [Bonding-devel] Re: [SET 2][PATCH 2/8][bonding] Propagating
	master's  settings toslaves
Date: 11 Aug 2003 22:31:43 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1060655503.1028.47.camel@jzny.localdomain>
References: <E791C176A6139242A988ABA8B3D9B38A014C9474@hasmsx403.iil.intel.com>
	 <200308111720.38472.shmulik.hen@intel.com>
	 <1060612481.1034.15.camel@jzny.localdomain>
	 <200308111925.38278.shmulik.hen@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Laurent DENIEL <laurent.deniel@thalesatm.com>,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
In-Reply-To: <200308111925.38278.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2003-08-11 at 12:25, Shmulik Hen wrote:

> Why have any kernel code other than device drivers in the first place 
> ?
> Why not move all the TCP/IP stack out of kernel space and put it in an 
> application ? Lets have the entire ARP mechanism in an appliaction 

Of course ARP should be moved out. Infact you bring out a very good
point;-> If ARP was out of the kernel a lot of the recent discussions on
ARP in relation to HA would have been nonexistent. The only reason they
are even being discussed its because so much of the policy exists in the
kernel. 
[BTW, there are several ARP implementations on Linux which try to move
it out of the kernel and leave some minimal functionality in the
kernel].

> and let it handle everything from routing tables management to arp 
> negotiation while the kernel will only know how to create arp packets 
> that it gets from that app and send them away ? It doesn't need to 
> have the know how.

Actually if you do this, then ARP packets need be generated in user
space.

> Say we do thing s your way and use the notification mechanism, how 
> long do you think it's going to take for the whole operation to 
> finish taking into consideration how the kernel runs user space 
> applications in comparison with kernel code? 

I dont have numbers. I would estimate less than a ms to go to user 
space, execute some simple policy config and come back.

> what happens when the 
> system is heavily loaded ? 

What happens now ? 

> What happens if the application dies for 
> some reason ? 

What happens when the kernel oopses? ;->

> Why should the bonding driver even care about routes or firewalling ?

I gave those as examples of policies that could be executed. There are
many reasons why you would wanna do a route redirection should a
specific link fail, most important being for path availability which is
a layer above link availability. Again, this is just an example, i may
wanna slice bread everytime a link goes down and add butter every time
one comes up. Ridiculuos as that may sound, point is you cant predict
what i wanna do with such events. 

> It's only meant to group several physical ethernet devices and group 
> them under one logical device to handle teaming solutions.

yes, those are basic services. You need to allow for more interesting
things.

cheers,
jamal
