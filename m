From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v6 net-next 05/12] gtp: Change to use gro_cells
Date: Thu, 26 Oct 2017 12:51:22 -0700
Message-ID: <CALx6S37Ub-epJr7YWEf_0Ngz0U8KXsArhZGqaOqL_m1Uh0F8hQ@mail.gmail.com>
References: <20171026190929.11619-1-tom@quantonium.net> <20171026190929.11619-6-tom@quantonium.net>
 <3760392e2813ec13d37430143f83571d@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tom Herbert <tom@quantonium.net>,
        "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Harald Welte <laforge@gnumonks.org>,
        Andreas Schultz <aschultz@tpip.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Rohit Seth <rohit@quantonium.net>,
        netdev-owner@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:45724 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932333AbdJZTvX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 15:51:23 -0400
Received: by mail-qt0-f193.google.com with SMTP id p1so5833608qtg.2
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 12:51:23 -0700 (PDT)
In-Reply-To: <3760392e2813ec13d37430143f83571d@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 26, 2017 at 12:35 PM, Subash Abhinov Kasiviswanathan
<subashab@codeaurora.org> wrote:
>> @@ -611,6 +615,8 @@ static const struct net_device_ops gtp_netdev_ops = {
>>
>>  static void gtp_link_setup(struct net_device *dev)
>>  {
>> +       struct gtp_dev *gtp = netdev_priv(dev);
>> +
>>         dev->netdev_ops         = &gtp_netdev_ops;
>>         dev->needs_free_netdev  = true;
>>
>> @@ -630,6 +636,8 @@ static void gtp_link_setup(struct net_device *dev)
>>                                   sizeof(struct iphdr) +
>>                                   sizeof(struct udphdr) +
>>                                   sizeof(struct gtp0_header);
>> +
>> +       gro_cells_init(&gtp->gro_cells, dev);
>>  }
>>
>
> Hi Tom
>
> This needs a check in case the initialization failed and moved to
> ndo_init().
> Eric spotted a similar bug in rmnet and vxlan.
>
Thanks Subash. Looks like vxlan has same issue (I used that code as a
reference :-) ). Will fix both.

Tom

>
> --
> Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
> a Linux Foundation Collaborative Project
