From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netpoll: Check for skb->queue_mapping
Date: Thu, 06 Apr 2017 12:14:16 -0700
Message-ID: <1491506056.10124.81.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1491444383-29017-1-git-send-email-tushar.n.dave@oracle.com>
         <1491474377.10124.57.camel@edumazet-glaptop3.roam.corp.google.com>
         <5927b630-865e-b7af-33a1-1a6b772e3fb7@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, brouer@redhat.com,
        netdev@vger.kernel.org, sowmini.varadhan@oracle.com
To: tndave <tushar.n.dave@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:35905 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755610AbdDFTOS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 15:14:18 -0400
Received: by mail-io0-f173.google.com with SMTP id l7so36343447ioe.3
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 12:14:18 -0700 (PDT)
In-Reply-To: <5927b630-865e-b7af-33a1-1a6b772e3fb7@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-04-06 at 12:07 -0700, tndave wrote:

> > +			q_index = q_index % dev->real_num_tx_queues;
> cpu interrupted here and dev->real_num_tx_queues has reduced!
> > +			skb_set_queue_mapping(skb, q_index);
> > +		}
> > +		txq = netdev_get_tx_queue(dev, q_index);
> or cpu interrupted here and dev->real_num_tx_queues has reduced!

If dev->real_num_tx_queues can be changed while this code is running we
are in deep deep trouble.

Better make sure that when control path does this change, device (and/pr
netpoll) is frozen and no packet can be sent.
