From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH][IPSEC] IPsec policy can be matched by ICMP type and code
Date: Wed, 11 Aug 2004 13:14:19 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF94FC19D3.2EA706DF-ON88256EED.006875F7-88256EED.006980E7@us.ibm.com>
References: <20040810230144.2a68914b.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: nakam@linux-ipv6.org, netdev@oss.sgi.com, usagi-core@linux-ipv6.org,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040810230144.2a68914b.davem@redhat.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I may be catching this out of context, but...

raw sockets predate VJ contributions by many years and are
typically used by protocols not in the kernel. The original "ping"
used raw sockets, as well as routing protocols like BGP and RIP
which are directly encapsulated in IP, without a separate transport
protocol. The original traceroute I believe used UDP and just set
the TTL-- I don't believe it used raw sockets at all. Don't know what
the current versions do; haven't looked in a while.

And IPv6 does support raw sockets; it just doesn't let you
generate bad checksums and some header fields, I expect
to make it harder to write attack software.

                                        +-DLS




"David S. Miller" <davem@redhat.com> 
Sent by: netdev-bounce@oss.sgi.com
08/10/2004 11:01 PM

To
yoshfuji@linux-ipv6.org
cc
nakam@linux-ipv6.org, netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Subject
Re: [PATCH][IPSEC] IPsec policy can be matched by ICMP type and code






On Tue, 10 Aug 2004 10:32:29 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> Does it make sense to excude IPPPROTO_RAW sockets and/or hdrincl 
sockets,
> which would be 100% truly raw socket?
> Or, do we add some socket option for this?
>
> Mip6 is required to exchange ipsec'ed datagrams (!= IPPROTO_RAW).
> (as I told you at Networking Summit if I remember correctly),
> so we need some sort of the patch, anyway.

This is what Alexey told me when I last spoke with him
about this:

Return-Path: <kuznet@ms2.inr.ac.ru>
Received: from localhost (IDENT:davem@localhost.localdomain [127.0.0.1])
by pizda.ninka.net (8.9.3/8.9.3) with ESMTP id QAA27793
for <davem@localhost>; Sat, 17 May 2003 16:28:26 -0700
From: kuznet@ms2.inr.ac.ru
Received: from localhost.localdomain [127.0.0.1]
by localhost with POP3 (fetchmail-6.2.2)
for davem@localhost (single-drop); Sat, 17 May 2003 16:28:26 -0700 (PDT)
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com 
[172.16.52.254])
by devserv.devel.redhat.com (8.11.6/8.11.0) with ESMTP id h4HNSr500334
for <davem@devserv.devel.redhat.com>; Sat, 17 May 2003 19:28:53 -0400
Received: from mx1.redhat.com (mx1.redhat.com [172.16.48.31])
by int-mx1.corp.redhat.com (8.11.6/8.11.6) with SMTP id h4HNSrI11137
for <davem@redhat.com>; Sat, 17 May 2003 19:28:53 -0400
Received: from dub.inr.ac.ru (dub.inr.ac.ru [193.233.7.105])
by mx1.redhat.com (8.11.6/8.11.6) with SMTP id h4HNSqH20272
for <davem@redhat.com>; Sat, 17 May 2003 19:28:52 -0400
Received: (from kuznet@localhost) by dub.inr.ac.ru (8.6.13/ANK) id 
DAA10631 for davem@redhat.com; Sun, 18 May 2003 03:28:45 +0400
Message-Id: <200305172328.DAA10631@dub.inr.ac.ru>
Subject: Re: dst_pmtu() check in ip_output()
To: davem@redhat.com (David S. Miller)
Date: Sun, 18 May 2003 03:28:45 +0400 (MSD)
In-Reply-To: <20030514.184139.55739273.davem@redhat.com> from "David S. 
Miller" at May 14, 2003 06:41:39 PM
X-Mailer: ELM [version 2.5 PL6]
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hello!

> Let's ask the following question: What is difference between adding
> transformation locally, and adding it at some hop on the way to
> destination?
>
> I can already hear answers of the form "It is same difference as
> that between tunnel and transport mode." :-)

Exactly.

Plus one more thing: when you noticed pathology with raw socket
you referred to "What does user expect?".

Use of raw socket is pathological itself, f.e. IPv6 does not even
have such a concept. It is used by (and invented by VJ for) traceroute.
And beyond this it is used by various testing and attacker's software.
Shortly, the packet which it generates are _tricky_ by user desire,
when user wants to test (or attack) someone.

So, I would expect the packet is not transformed locally at all.
Remember f.e. that it can be an _IPsec_ packet already.

Alexey

PS. This is the first mail which I send from new account. Please,
tell me if it looks unusual.
