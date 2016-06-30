From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net] net: poll tx timeout only on active tx queues
Date: Thu, 30 Jun 2016 17:47:19 +0300
Message-ID: <CALzJLG-pjeZnOQ3FfZMLCz5KC-eXWWrTZS4yNi-+UYY=2T549A@mail.gmail.com>
References: <1467295085-9204-1-git-send-email-saeedm@mellanox.com> <1467296892.11238.24.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <tom@herbertland.com>,
	Mohamad Haj Yahia <mohamad@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:36735 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932094AbcF3Orj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 10:47:39 -0400
Received: by mail-qk0-f196.google.com with SMTP id r68so14329535qka.3
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 07:47:39 -0700 (PDT)
In-Reply-To: <1467296892.11238.24.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 30, 2016 at 5:28 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-06-30 at 16:58 +0300, Saeed Mahameed wrote:
>> -                     for (i = 0; i < dev->num_tx_queues; i++) {
>> +                     for (i = 0; i < dev->real_num_tx_queues; i++) {
>>                               struct netdev_queue *txq;
>>
>>                               txq = netdev_get_tx_queue(dev, i);
>
> Strange, why don't you change all others helpers that are using
> num_tx_queues ?
>

which other helpers ?
since this function assumes that all tx queues are started and if a
non real_txq is stopped for more that timeout period it will start
shouting call traces and warnings.

> Which driver had a problem with this code ?

non yet.
currently all the device driver call  netif_tx_start_all_queues(dev)
on open to W/A this issue. which is strange since only
real_num_tx_queues are active.
