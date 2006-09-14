From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] make ipv4 multicast packets only get delivered to sockets	that
 are joined to group
Date: Thu, 14 Sep 2006 08:39:39 -0700
Message-ID: <OFFA78855E.1D1E53C6-ON882571E9.00538B2B-882571E9.005607E5@us.ibm.com>
References: <20060914103037.GB19959@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Jeff Layton <jlayton@poochiereds.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750842AbWINPjt@vger.kernel.org>
In-Reply-To: <20060914103037.GB19959@ms2.inr.ac.ru>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote on 09/14/2006 03:30:37 AM:

> Hello!
> 
> >         No, it returns 1 (allow) if there are no filters to explicitly
> > filter it. I wrote that code. :-)
> 
> I see. It did not behave this way old times.
> 
> From your mails I understood that current behaviour matches another
> implementations (BSD whatever), is it true?

Hi, Alexey,

If you mean IPv6 code in current BSD derivatives, I don't know.

The IPv6 behaviour was different from IPv4 on Linux and was changed for
compatibility with IPv4 (discussion on netdev agreed that binding
should determine socket delivery, not group membership, or simply
that there was no reason to be different from long-standing IPv4 
practice).

The IPv4 code is that way for compatibility with everything else since
about ~4.3BSD (with the possible exception of Solaris 8, apparently).

FWIW, I think Deering's original interpretation is correct. Adding
a multicast address to an interface by joining a group is little
different from adding a unicast address via SIOCSIFADDR, which
certainly does affect packets delivered to the machine and to any
INADDR_ANY-bound socket. Binding to the multicast address and not
INADDR_ANY will give you only packets for that group, if that's
what you want, just as in the unicast address-specific bind.

                                                        +-DLS
