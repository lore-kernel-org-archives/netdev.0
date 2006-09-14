From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] make ipv4 multicast packets only get delivered to
	sockets	that are joined to group
Date: Thu, 14 Sep 2006 13:12:08 -0400
Message-ID: <1158253928.12479.3.camel@galen.zko.hp.com>
References: <OFFA78855E.1D1E53C6-ON882571E9.00538B2B-882571E9.005607E5@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:32958 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1750775AbWINRML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 13:12:11 -0400
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OFFA78855E.1D1E53C6-ON882571E9.00538B2B-882571E9.005607E5@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-09-14 at 08:39 -0700, David Stevens wrote:
> Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote on 09/14/2006 03:30:37 AM:
> 
> > Hello!
> > 
> > >         No, it returns 1 (allow) if there are no filters to explicitly
> > > filter it. I wrote that code. :-)
> > 
> > I see. It did not behave this way old times.
> > 
> > From your mails I understood that current behaviour matches another
> > implementations (BSD whatever), is it true?
> 
> Hi, Alexey,
> 
> If you mean IPv6 code in current BSD derivatives, I don't know.
> 
> The IPv6 behaviour was different from IPv4 on Linux and was changed for
> compatibility with IPv4 (discussion on netdev agreed that binding
> should determine socket delivery, not group membership, or simply
> that there was no reason to be different from long-standing IPv4 
> practice).
> 
> The IPv4 code is that way for compatibility with everything else since
> about ~4.3BSD (with the possible exception of Solaris 8, apparently).
> 
> FWIW, I think Deering's original interpretation is correct. Adding
> a multicast address to an interface by joining a group is little
> different from adding a unicast address via SIOCSIFADDR, which
> certainly does affect packets delivered to the machine and to any
> INADDR_ANY-bound socket. Binding to the multicast address and not
> INADDR_ANY will give you only packets for that group, if that's
> what you want, just as in the unicast address-specific bind.
> 
>                                                         +-DLS

There was an IETF daft quite a while ago that proposed something similar
to the patch that originated this thread.  In case anyone is curious,
here is the link:
http://tools.ietf.org/wg/ipv6/draft-arunt-ipv6-multicast-filtering-rules-01.txt

That work got a few positive comments, but didn't really go anywhere.

-vlad

