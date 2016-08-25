From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net 2/2] sctp: not copying duplicate addrs to the assoc's
 bind address list
Date: Thu, 25 Aug 2016 12:03:30 +0800
Message-ID: <CADvbK_dJbaze7qMsDp-7x0xANsXZX=JfYBNhKOo=2VgbM_ywZg@mail.gmail.com>
References: <cover.1471605833.git.lucien.xin@gmail.com> <130956b1e880eab780162a795fde156d61d4de0f.1471605833.git.lucien.xin@gmail.com>
 <20160819175007.GB3578@hmsreliant.think-freely.org> <CADvbK_do3kQSotq7-PbvoCBBSwOBBdZtx=rR+Q2XX3_bhV4_0w@mail.gmail.com>
 <20160822142538.GA10323@hmsreliant.think-freely.org> <20160824112338.GB11144@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Neil Horman <nhorman@tuxdriver.com>,
        network dev <netdev@vger.kernel.org>,
        linux-sctp@vger.kernel.org, davem <davem@davemloft.net>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35430 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754785AbcHYFHv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 01:07:51 -0400
In-Reply-To: <20160824112338.GB11144@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Or add a refcnt to its members. </idea>
> NETDEV_UP, it gets a ++ if it's already there
> NETDEV_DOWN, it gets a -- and cleans it up if it reaches 0
> And the rest probably could stay the same.
>
Yes, it could also avoid the issue of amounts of duplicate addrs.
or add a nic index variable to  its members.

But I still prefer the current patch.
1. This issue only happens when server bind 'ANY' addresses.
    we don't need to add any new members to struct sctp_sockaddr_entry.
    especially if it's a really corner issue,  we fix this as an improvement.

2. It's yet two issues  here, the duplicate addrs may be from
   a) different local NICs.
   b) the same one NIC.
   It may be unexpectable to filter them in NETDEV_UP/DOWN events.

3. We check it only when sctp really binds it, just like sctp_do_bind.

What do you think ?
