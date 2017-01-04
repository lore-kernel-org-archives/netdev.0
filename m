From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 2/2] tools: psock_tpacket: verify that packet was
 received on lo before counting it
Date: Wed, 4 Jan 2017 11:07:25 -0500
Message-ID: <CAF=yD-+7Lj=boiJy6BPPJA-+-MrWqDd38-OFPcsWurUXkrwtzA@mail.gmail.com>
References: <cover.1483482971.git.sowmini.varadhan@oracle.com>
 <3451a2008d953f33d6576a35eaefecad883eaeb5.1483482971.git.sowmini.varadhan@oracle.com>
 <CAF=yD-+d-cgE1dxCcrfNZfgVk4_wjYMHHoQ=BN7bnJ-txbM-+Q@mail.gmail.com>
 <20170104144424.GD9641@oracle.com> <CAF=yD-KUw8M+RGnN2eXLVgv836F6mxd4+b0h=2CP6X7mv+ScWg@mail.gmail.com>
 <20170104151346.GE9641@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kselftest@vger.kernel.org,
        Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>, shuah@kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:35269 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031410AbdADQIG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 11:08:06 -0500
In-Reply-To: <20170104151346.GE9641@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 4, 2017 at 10:13 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (01/04/17 10:03), Willem de Bruijn wrote:
>>
>> This approach is less restrictive. It still allows incorrect packets
>> to be enqueued in the time between the socket call and attaching the
>> bpf filter. Also, if packets are restricted to a single packet, using
>> bind with sll_ifindex is simpler.
>
> Do you want me to change this to first set up pfsocket() with
> proto 0, then set up filter, and then bind_ring() to the desired
> ifindex with ETH_P_ALL?

Please do. Then the patch is just a one-line change to
the third argument of the socket call. Thanks!
