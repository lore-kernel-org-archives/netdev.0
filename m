From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: A question on the design of OVS GRE tunnel
Date: Mon, 8 Jul 2013 09:28:00 -0700
Message-ID: <CALnjE+q4L9Q8Ebj+O-D8xQHyzSo=FZrb7A-XVEGERzeN-MZMGQ@mail.gmail.com>
References: <1373277065.8227.26.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog130.obsmtp.com ([74.125.149.143]:50908 "HELO
	na3sys009aog130.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751549Ab3GHQ2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 12:28:10 -0400
Received: by mail-qe0-f44.google.com with SMTP id 5so2430905qeb.31
        for <netdev@vger.kernel.org>; Mon, 08 Jul 2013 09:28:00 -0700 (PDT)
In-Reply-To: <1373277065.8227.26.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 8, 2013 at 2:51 AM, Cong Wang <amwang@redhat.com> wrote:
> Hi, Jesse, Pravin
>
> I have a question on the design of OVS GRE tunnel. Why OVS GRE tunnel
> doesn't register a netdev? I understand it is enough for GRE to function
> without registering a netdev, just a GRE vport is sufficient and
> probably even simpler.
>
kernel-gre device has gre-parameters/state associated with it and
ovs-gre-vport is completely stateless. ovs-gre state is in user-space
which make kernel module alot simpler. Therefore I doubt it will be
easy or simpler to use netdev at this point.

> However, I noticed there is some problem with such design:
>
> I saw very bad performance with the _default_ setup with OVS GRE. After
> digging it a little bit, clearly the cause is that OVS GRE tunnel adds
> an outer IP header and a GRE header for every packet that passed to it,
> which could result in a packet whose length is larger than the MTU of
> the uplink, therefore after the packet goes through OVS, it has to be
> fragmented by IP before going to the wire.
>
I do not understand what do you mean, gre packets greater than MTU
must be fragmented before sent on wire and it is done by GRE-GSO code.

> Of course we can workaround this problem by:
>
> 1) lower down the MTU of the first net device to reserve some room for
> GRE header
>
> 2) pass vnet_hdr=on to KVM guests so that packets going out there are
> still GSO packets even on hosts (I never try this, just analysis it by
> reading code)
>
> Do we have to live with this? Can we solve this problem at OVS layer? So
> that no matter how large the packets are we can avoid IP fragmentation?
> One solution in my mind is registering a netdev for OVS GRE tunnel too,
> so that we could probably reuse GRO cells, thus packets can be merged
> before OVS processing them, and it will be segmented again before going
> to the wire. But I could easily miss something here. ;)
>
> What do you think? Any better idea to fix this?
>
> Thanks!
>
