From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: source route ignored in favor of local interface
Date: Tue, 01 Mar 2011 13:05:20 -0600
Message-ID: <4D6D4370.5040308@genband.com>
References: <loom.20110301T154947-689@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joe Buehler <aspam@cox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og111.obsmtp.com ([64.18.2.175]:34785 "EHLO
	exprod7og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645Ab1CATH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 14:07:26 -0500
In-Reply-To: <loom.20110301T154947-689@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/01/2011 08:57 AM, Joe Buehler wrote:
> I have a LINUX box talking on many different networks at the same time.  Since
> IP addresses on the networks can overlap (they are completely different
> networks) we use source routing and NAT to get packets going in and out of the
> right interfaces.
> 
> Everything works great, with one exception.  If I try to talk to a remote host
> that happens to have the same IP address as one of my interfaces, the kernel
> routes the packet to the local interface.
> 
> It looks to me as though the problem is that the source routes are lower
> priority than the local interfaces.  As soon as the kernel sees a destination
> address that matches a local interface it routes to the local interface and pays
> no attention to the source route.
> 
> I consider this a bug.  Is there any way to change this behavior?

How exactly do you expect it to handle this case?  You've explicitly
told your host that its address is X, so why would it expect to find
that address assigned to another machine on the network?  Suppose you
have an app listening on INADDR_ANY, and it gets a packet from that
adddres--how does it know whether the packet is destined to the local
machine or the remote one?

If you really want to modify things, have you looked at your ip rules?
"ip ru" will dump them.  Typically it looks something like

0:      from all lookup local
32766:  from all lookup main
32767:  from all lookup default

The last item in each row is the name of the routing table.  As you can
see, the first rule is for local interfaces, and a later rule deals with
the main and default routing tables.

You could move the local lookup to rule 1 and add in a new rule 0
specifically dealing with your situation.

Chris



-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
