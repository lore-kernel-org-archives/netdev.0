From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next 01/10] net_sched: add the ability to defer skb freeing
Date: Wed, 15 Jun 2016 05:39:07 -0700
Message-ID: <CANn89i+d-vVeMoDPhAkfZw0Y_=ST9UmBto00Afs=Jzh8gR8NyA@mail.gmail.com>
References: <1465874519-25494-1-git-send-email-edumazet@google.com>
 <1465874519-25494-2-git-send-email-edumazet@google.com> <20160615143346.2300e64b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:36638 "EHLO
	mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932130AbcFOMjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 08:39:10 -0400
Received: by mail-yw0-f177.google.com with SMTP id v137so18542780ywa.3
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 05:39:10 -0700 (PDT)
In-Reply-To: <20160615143346.2300e64b@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2016 at 5:33 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Mon, 13 Jun 2016 20:21:50 -0700
>
>
> This looks a lot like kfree_skb_list()....
>
> What about bulk free'ing SKBs here?

We are in a very slow path here. Once in a while a potentially huge
qdisc is dismantled.

The important point is to free these skbs outside of any mutex/lock/bh
, not gain 5% on the actual freeing ;)

Now if you have a use case where these operations happen often enough,
then I believe you have a problem you need to fix !
