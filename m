From: Maximilian Wilhelm <max@rfc2324.org>
Subject: Re: [RFC] Stable interface index option
Date: Tue, 1 Dec 2015 16:50:52 +0100
Message-ID: <20151201155052.GA14984@principal.rfc2324.org>
References: <20151201120420.GT12404@principal.rfc2324.org>
 <20151201153441.GA17843@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.rfc2324.org ([31.172.8.67]:39523 "EHLO mail.rfc2324.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751324AbbLAPuy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2015 10:50:54 -0500
Received: from rfc2324.org ([31.172.8.84] helo=principal.rfc2324.org)
	by mail.rfc2324.org with esmtp rfc2324.org Mailserver
	id 1a3nCe-0005CS-TE
	for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 16:50:53 +0100
Content-Disposition: inline
In-Reply-To: <20151201153441.GA17843@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anno domini 2015 Sowmini Varadhan scripsit:

> On (12/01/15 13:04), Maximilian Wilhelm wrote:

> > The reason we would like to have those is quite simple: As we operate
> > a somewhat larger network we would like to monitor it accordingly and
> > see when links get saturated etc. Therefore we used snmp based
> > solutions and the net-snmp daemon on all the boxes. Now SNMP uses
> > interface indexes for identifying the interfaces. If they aren't
> > stable the monitoring software will see a lot of new interfaces now
> > and then, e.g. after a OpenVPN server/client restarted (which is bad)
> > or even mix up interfaces (which is worse).
> 
> FWIW, this is how router implementations such as cisco network OS-es
> deal with this issue- every interface has 2 32-bit integers associated
> with it, one is the "snmp-ifindex", conformant with rfc 2863, 
> that never changes, and encodes positional information like slot#,
> chassis#, card type etc.  This number is sparse (i.e., it
> is not necessarily a consecutive number space) Encoding is implementation
> specific, of course, and macros are supplied if you want to look into
> the encoding itself.
> 
> the other number is the one used internally by the network stack,
> and is subject to frequent change, as interfaces come and go (up/down,
> virtual interfaces change etc). This is a packed number-space- next
> available index is handed to each interface as it comes up.
> 
> SNMP mibs publish the first number, and apps can use that number
> to uniquely identify an interface. 
> 
> If there are enough apps that rely on an immutable index to identify
> an interface, it might be worthwhile to consider this type of approach.

I would assume that at least all snmp implementations and connected
system (libreNMS, Observium and the like) do.

> > +	if (!dev->ifindex) {
> > +		if (strcmp (dev->name, "gre_ffrl_fra_a") == 0) {
> > +			ifindex = 23;
> > +		} else if (strcmp (dev->name, "bb-pad-cr01") == 0) {
> > +			ifindex = 42;
> > +		}
> 
> I'm not sure I understand how this would work- are we going to 
> pin down the ifindex for some subset of interfaces?

I'm not sure what your idea is, but I guess we might mean the same
thing:

What I have in mind is that the user can supply a list of (ifname ->
ifindex) entries via a sysfs/procfs interface and if such a list is
present, the kernel will search the list for every ifname which is
registered and check if there is an entry. If there is, the ifindex
for this entry is used. If there is no entry found for the given
ifname, the usual algorithm is used (therefore inherently providing
backward compatibility).

What I'm not sure about is what to do if there is any entry in the
list but the ifindex is already in use. One option would be to fail
the register call because the user wanted this particular ifindex and
therefore is seen responsible for ensuring its availability. The other
option is to silenty fall back to the usual approach (as my hardcoded
hack currently does).

I hope I could clarify on my idea?

Kind regards
Max
-- 
"Du kannst die Grundlagen von C. Das einzige, was C++ Dir noch gibt, ist mehr Schmerz!
 Und ein paar mehr Schrotflinten in die Hand..."
  -- Matthias Bolte
