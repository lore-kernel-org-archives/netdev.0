From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 2/2] tools: psock_tpacket: verify that packet was
 received on lo before counting it
Date: Wed, 4 Jan 2017 09:30:08 -0500
Message-ID: <CAF=yD-+d-cgE1dxCcrfNZfgVk4_wjYMHHoQ=BN7bnJ-txbM-+Q@mail.gmail.com>
References: <cover.1483482971.git.sowmini.varadhan@oracle.com> <3451a2008d953f33d6576a35eaefecad883eaeb5.1483482971.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kselftest@vger.kernel.org,
        Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>, shuah@kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:34110 "EHLO
        mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936381AbdADObL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 09:31:11 -0500
In-Reply-To: <3451a2008d953f33d6576a35eaefecad883eaeb5.1483482971.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 3, 2017 at 6:27 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> Packets from any/all interfaces may be queued up on the PF_PACKET socket
> before it is bound to the loopback interface by psock_tpacket, and
> when these are passed up by the kernel, they should not be counted
> toward the conditions needed to pass/fail the Rx tests.

The common and simpler solution to this problem is to open the socket
with protocol 0 to reject all packets, add the BPF filter and only then bind
with sll_ifindex set to lo. That way no false positives can arrive.
