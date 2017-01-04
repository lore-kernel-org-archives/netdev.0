From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 2/2] tools: psock_tpacket: verify that packet was
 received on lo before counting it
Date: Wed, 4 Jan 2017 10:03:43 -0500
Message-ID: <CAF=yD-KUw8M+RGnN2eXLVgv836F6mxd4+b0h=2CP6X7mv+ScWg@mail.gmail.com>
References: <cover.1483482971.git.sowmini.varadhan@oracle.com>
 <3451a2008d953f33d6576a35eaefecad883eaeb5.1483482971.git.sowmini.varadhan@oracle.com>
 <CAF=yD-+d-cgE1dxCcrfNZfgVk4_wjYMHHoQ=BN7bnJ-txbM-+Q@mail.gmail.com> <20170104144424.GD9641@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kselftest@vger.kernel.org,
        Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>, shuah@kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f196.google.com ([209.85.217.196]:33970 "EHLO
        mail-ua0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754065AbdADPEY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 10:04:24 -0500
In-Reply-To: <20170104144424.GD9641@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 4, 2017 at 9:44 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (01/04/17 09:30), Willem de Bruijn wrote:
>>
>> The common and simpler solution to this problem is to open the socket
>> with protocol 0 to reject all packets, add the BPF filter and only then bind
>> with sll_ifindex set to lo. That way no false positives can arrive.
>
> Yes, I thought of that too (and I've seen that done in one commercial
> implementation), but given that tpacket nicely returns the incoming
> interface, I figured, why not use the test prog to use this (thus
> verifying it, and also showing how to use it)

This approach is less restrictive. It still allows incorrect packets
to be enqueued in the time between the socket call and attaching the
bpf filter. Also, if packets are restricted to a single packet, using
bind with sll_ifindex is simpler.
