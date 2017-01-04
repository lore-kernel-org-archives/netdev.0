From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 2/2] tools: psock_tpacket: verify that packet
 was received on lo before counting it
Date: Wed, 4 Jan 2017 11:12:20 -0500
Message-ID: <20170104161220.GF9641@oracle.com>
References: <cover.1483482971.git.sowmini.varadhan@oracle.com>
 <3451a2008d953f33d6576a35eaefecad883eaeb5.1483482971.git.sowmini.varadhan@oracle.com>
 <CAF=yD-+d-cgE1dxCcrfNZfgVk4_wjYMHHoQ=BN7bnJ-txbM-+Q@mail.gmail.com>
 <20170104144424.GD9641@oracle.com>
 <CAF=yD-KUw8M+RGnN2eXLVgv836F6mxd4+b0h=2CP6X7mv+ScWg@mail.gmail.com>
 <20170104151346.GE9641@oracle.com>
 <CAF=yD-+7Lj=boiJy6BPPJA-+-MrWqDd38-OFPcsWurUXkrwtzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kselftest@vger.kernel.org,
        Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>, shuah@kernel.org
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27352 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936542AbdADQMh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 11:12:37 -0500
Content-Disposition: inline
In-Reply-To: <CAF=yD-+7Lj=boiJy6BPPJA-+-MrWqDd38-OFPcsWurUXkrwtzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/04/17 11:07), Willem de Bruijn wrote:
> 
> Please do. Then the patch is just a one-line change to
> the third argument of the socket call. Thanks!

ok but it's going to be more than a one-line change. Today you
have
        sock = pfsocket(version);
        memset(&ring, 0, sizeof(ring));
        setup_ring(sock, &ring, version, type);
        mmap_ring(sock, &ring);
        bind_ring(sock, &ring);
        walk_ring(sock, &ring);

And the pair_udp_setfilter() only gets set up out of 
walk_ring. I think you want to move that up to be done before
bind_ring.
