From: jamal <hadi@cyberus.ca>
Subject: Re: [Bugme-new] [Bug 14837] New: gretap does not fragment IP
 packets
Date: Sat, 19 Dec 2009 07:55:03 -0500
Message-ID: <1261227303.11973.2.camel@bigi>
References: <bug-14837-10286@http.bugzilla.kernel.org/>
	 <20091218153209.45042a58.akpm@linux-foundation.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, benoit.papillault@free.fr
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:28405 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675AbZLSMzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Dec 2009 07:55:07 -0500
Received: by qw-out-2122.google.com with SMTP id 3so757941qwe.37
        for <netdev@vger.kernel.org>; Sat, 19 Dec 2009 04:55:06 -0800 (PST)
In-Reply-To: <20091218153209.45042a58.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-12-18 at 15:32 -0800, Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Fri, 18 Dec 2009 23:10:01 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=14837
> > 
> >            Summary: gretap does not fragment IP packets
> >            Product: Networking
> >            Version: 2.5
> >     Kernel Version: 2.6.32
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: IPV4
> >         AssignedTo: shemminger@linux-foundation.org
> >         ReportedBy: benoit.papillault@free.fr
> >         Regression: No
> > 
> > 
> > When gretap is used to encapsulate Ethernet packets into IP packets, the
> > encapsulated IP packets are larger than the original Ethernet packet, as
> > expected.
> > 
> > Let's say you create a gre0 interface with a 1500 bytes MTU (since this
> > interface will latter be inserted in a bridge interface, its MTU must be 1500).
> > And Let's say the GRE encapsulated packet (now larger than 1500 bytes) is going
> > to be routed over an IP interface with a 1500 bytes MTU.
> > 
> > The expected behavior would be that the encapsulated packet be fragmented. The
> > observed behavior is that any encapsulated packets over 1500 bytes are simply
> > dropped and an ICMP "fragmentation needed" message is sent to ... who knows.

Sending back an ICMP is good behavior. Sending it "who knows" is not ;->
Make sure it is sent to the originator of the packet. The originator of
the packet should play nice and reduce the path mtu.

One work around is to reduce the gre device mtu to something less than
1500B.

cheers,
jamal

