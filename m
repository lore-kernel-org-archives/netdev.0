From: James Courtier-Dutton <James@superbug.co.uk>
Subject: Re: gratuitous arp
Date: Sun, 26 Nov 2006 13:08:41 +0000
Message-ID: <456991D9.7000503@superbug.co.uk>
References: <Pine.LNX.4.64.0611251526040.8068@twinlark.arctic.org> <4568F663.7090805@superbug.co.uk> <Pine.LNX.4.64.0611251819310.8068@twinlark.arctic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchor-post-32.mail.demon.net ([194.217.242.90]:12300 "EHLO
	anchor-post-32.mail.demon.net") by vger.kernel.org with ESMTP
	id S935375AbWKZNIj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Nov 2006 08:08:39 -0500
To: dean gaudet <dean@arctic.org>
In-Reply-To: <Pine.LNX.4.64.0611251819310.8068@twinlark.arctic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dean gaudet wrote:
> On Sun, 26 Nov 2006, James Courtier-Dutton wrote:
> 
>> dean gaudet wrote:
>>> hi...
>>>
>>> i ran into some problems recently which would have been avoided if my box
>>> did a gratuitous arp as it brought up all interfaces (the router took
>>> forever to timeout the ARP entries for interface aliases).  so i set about
>>> looking to see why that wasn't happening.
> ...
>> Are you 100% sure about this?
>> Have you done a packet sniff on the network?
>> A lot of routers ignore gratuitous arp for security reasons.
> 
> yeah i've done some packet sniffing to verify this.
> 
> here's what happened (twice now):  i upgraded a (normally busy) box, so 
> the MAC address changed.  the router is a cisco (not managed by me).
> 
> debian reboot sequence at some point brings up the primary eth0 address 
> and very soon thereafter there will be an arp "who-has $default_gw tell 
> $primary_addr".  that's sufficient to get the cisco to update its ARP 
> cache for $primary_addr.  this isn't gratuitous arp, but does the trick 
> for the $primary_addr.
> 
> but there's no gratuitous arp for any eth0:N aliased interfaces... and the 
> cisco ARP cache on this ISP router seems to be set to a long timeout.  i 
> could reach eth0:N from local net, but couldn't get outside local net from 
> eth0:N.
> 
> issuing "arping -I eth0 -s $secondary_addr $default_gw" for each secondary 
> address updated the cisco ARP cache and i could then reach eth0:N 
> remotely.
> 
> so... that may not be exactly gratuitous arp, but basically i was stuck 
> until i forced the cisco to update its ARP cache for each of the secondary 
> addrs...
> 
> it seems to me it'd be nice for the init sequence to take care of this, so 
> that other folks don't have to spend time debugging similar problems.  i 
> just wanted to ask if i'm missing something obvious before i go open a 
> debian bug.  (i'm tempted to see if fedora does anything differently.)
> 
> thanks
> -dean

Ok, I think it is better to just do gratuitous arp on the primary interface.
If one starts doing it on secondary interfaces, one would then have to 
also do it for all proxy-arp addresses(if used), and thinks could start 
getting rather messy.

James

