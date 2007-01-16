From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: rare bad TCP checksum with 2.6.19?
Date: Tue, 16 Jan 2007 17:38:53 +0300
Message-ID: <45ACE37D.6030807@tls.msk.ru>
References: <E1H6OJU-0001EC-00@gondolin.me.apana.org.au> <45AB82F1.9000409@tls.msk.ru> <20070115201001.GA9510@gondor.apana.org.au> <45ABF620.3070405@tls.msk.ru> <20070116032739.GA12746@gondor.apana.org.au> <20070116033849.GA12856@gondor.apana.org.au> <45AC8813.9000204@tls.msk.ru> <20070116115053.GA16529@gondor.apana.org.au> <45ACC1DE.6090708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:20259 "EHLO hobbit.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751235AbXAPOi6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jan 2007 09:38:58 -0500
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <45ACC1DE.6090708@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Herbert Xu wrote:
[]
>> Since you're certain that this is being seen on the wire, one
>> possibility is that we've got a bug somewhere that's zeroing
>> skb->ip_summed on a packet with a partial checksum.
>>
>> One potential spot where this could happen is netfilter.
>> Patrick, do you know of any recent changes (this is happening
>> with 2.6.19) that might cause this?
> 
> The incremental HW checksum update stuff went in 2.6.19, so thats
> a prime suspect. Can't see where this could be happening though.
> 
> Michael, how exactly is netfilter involved in your setup?

I think it doesn't involved.

The captures I did were done on a router box, which indeed has some
netfilter stuff.  But:

 1) the capture has been done on an interface directly connected to
   the segment where the "testing" machine is located (not on the
   "external" interface)

 2) the "testing" machine itself does not have any netfilter modules
   loaded

 3) the packets looks exactly the same in at least 3 places (modulo
   the TTL values): on the sending machine, on the router (on the
   interface connected to the sending machine - in those 2 places,
   the TTL is the same), and at the receiving side, which is 20+
   hops away.

 4) I tried another machine today (upgraded from 2.6.17 to 2.6.19) -
   stand-alone, without any netfilter modules loaded (but it's under
   quite.. some load - see http://j.ns.dsbl.org/nsg/ -- with this load
   it'll die right after iptables module loading, it's a 600MHz Celeron
   box replying to 15000 DNS packets every secound) - it started showing
   the same behavior.

/mjt
