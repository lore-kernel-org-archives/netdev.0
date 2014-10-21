From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: Routing BUG with ppp over l2tp
Date: Tue, 21 Oct 2014 10:15:57 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1410211007210.1159-100000@iolanthe.rowland.org>
References: <54456F15.9070206@workingcode.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: James Chapman <jchapman@katalix.com>, <linux-ppp@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: James Carlson <carlsonj@workingcode.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <54456F15.9070206@workingcode.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Oct 2014, James Carlson wrote:

> >> Otherwise, contact the maintainer of that VPN server.  It's just plain
> >> old broken, and life's too short for broken software.
> > 
> > It is an old Cisco security appliance, no doubt well past End-Of-Life.  
> > I'm starting to think it might be preferable to throw the thing away 
> > and start up a VPN server on the department's firewall (which is a 
> > Linux box) instead.
> 
> That sounds like a good (and easier to support) solution.

Okay.  I looked into iptables, but it doesn't seem to provide any way 
to prevent a packet from being routed through a particular interface. 
:-(

On the other hand, I tried writing a short /etc/ppp/ip-up.local script
that changes the destination address of the ppp interface and adds a
default route to the new, correct address.  It worked!  It's not a
perfect solution, because there's still a short window in which the
interface is up with the wrong address.  A few packets get lost and a
deadlock could occur.  But at least it's simple and non-invasive, and
it definitely proves the address conflict was indeed the cause of the
problem.

Changing pppd would be more foolproof.  But then I'd also have to 
change the programs that call it (xl2tpd and then NetworkManager), and 
doing all that doesn't seem worthwhile.

In the end, I think the best solution will be to replace the VPN 
server.

Thanks for your help,

Alan Stern

