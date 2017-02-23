From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] net/gtp: Add udp source port generation
 according to flow hash
Date: Thu, 23 Feb 2017 14:49:47 +0100
Message-ID: <20170223134947.GA4373@salvia>
References: <1487257141-11706-1-git-send-email-ogerlitz@mellanox.com>
 <576077949.135577.1487282291666.JavaMail.zimbra@tpip.net>
 <CAJ3xEMijwHpWfxUFcaCiAkP_0P8R2u6Cv4L=Vc3b_dPf+beOBg@mail.gmail.com>
 <CALx6S34ibBFpmZvxAtUn6oqgX9M8C1a3gg1iZrWWzwbswatUSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        Andreas Schultz <aschultz@tpip.net>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        laforge <laforge@gnumonks.org>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53682 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751034AbdBWNuA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 08:50:00 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 61E22ED914
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 14:49:54 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 52020DA81B
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 14:49:54 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 129F5DA80B
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 14:49:52 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <CALx6S34ibBFpmZvxAtUn6oqgX9M8C1a3gg1iZrWWzwbswatUSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 22, 2017 at 01:47:17PM -0800, Tom Herbert wrote:
> On Wed, Feb 22, 2017 at 1:29 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> > On Thu, Feb 16, 2017 at 11:58 PM, Andreas Schultz <aschultz@tpip.net> wrote:
> >> Hi Or,
> >> ----- On Feb 16, 2017, at 3:59 PM, Or Gerlitz ogerlitz@mellanox.com wrote:
> >>
> >>> Generate the source udp header according to the flow represented by
> >>> the packet we are encapsulating, as done for other udp tunnels. This
> >>> helps on the receiver side to apply RSS spreading.
> >>
> >> This might work for GTPv0-U, However, for GTPv1-U this could interfere
> >> with error handling in the user space control process when the UDP port
> >> extension  header is used in error indications.
> >
> >
> > in the document you posted there's this quote "The source IP and port
> > have no meaning and can change at any time" -- I assume it refers to
> > v0? can we identify in the kernel code that we're on v0 and have the
> > patch come into play?
> >
> >> 3GPP TS 29.281 Rel 13, section 5.2.2.1 defines the UDP port extension and
> >> section 7.3.1 says that the UDP source port extension can be used to
> >> mitigate DOS attacks. This would IMHO imply that the user space control
> >> process needs to know the TEID to UDP source port mapping.
> >
> >> The other question is, on what is this actually hashing. When I understand
> >> the code correctly, this will hash on the source/destination of the orignal
> >> flow. I would expect that a SGSN/SGW/eNodeB would like the keep flow
> >> processing on a per TEID base, so the port hashing should be base on the TEID.
> >
> > is it possible for packets belonging to the same TCP session or UDP
> > "pseudo session" (given pair of src/dst ip/port) to be encapsulated
> > using different TEID?
> >
> > hashing on the TEID imposes a harder requirement on the NIC HW vs.
> > just UDP based RSS.
> 
> This shouldn't be taken as a HW requirement and it's unlikely we'd add
> explicit GTP support in flow_dissector. If we can't get entropy in the
> UDP source port then IPv6 flow label is a potential alternative (so
> that should be supported in NICs for RSS).

According to specs, section 4.4.2.3 Encapsulated T-PDU, TS 29.281.

"The UDP Source Port is a locally allocated port number at the sending
GTP-U entity."

Older specs that refer to GTP-U such as TS 09.60 and TS 29.060 also
state the same.

So Or patch looks fine to me.
