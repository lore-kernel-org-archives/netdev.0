From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH next v2 0/7] Introduce l3_dev pointer for L3 processing
Date: Mon, 14 Mar 2016 11:13:35 -0700
Message-ID: <CAM_iQpXkXub85d=oLRnLVQCfeDsyDBfmUW0xAke45o83nA5fZg@mail.gmail.com>
References: <1457560189-12870-1-git-send-email-mahesh@bandewar.net>
	<56E14296.5010103@6wind.com>
	<CAM_iQpUFB4TO=nByzT-8ZESKL8ecLJKYRdCcYRPWBqQ10_Dtnw@mail.gmail.com>
	<CAF2d9jhv3-GNqy3jWfPPUBgnFuOwpmMtrKSkm+9SVK7tPhEQeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Mahesh Bandewar <mahesh@bandewar.net>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:33067 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932356AbcCNSNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 14:13:36 -0400
Received: by mail-yw0-f173.google.com with SMTP id d65so178153172ywb.0
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 11:13:35 -0700 (PDT)
In-Reply-To: <CAF2d9jhv3-GNqy3jWfPPUBgnFuOwpmMtrKSkm+9SVK7tPhEQeA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 13, 2016 at 5:01 PM, Mahesh Bandewar <maheshb@google.com> wrote:
>>> If I understand correctly (and as Cong already said), information are
>>> leaking
>>> between netns during the input phase. On the tx side, skb_scrub_packet() is
>>> called, but not on the rx side. I think it's wrong. There should be an
>>> explicit
>>> boundary.
>>
>> That is not what I am complaining about.
>>
>> I dislike the trick of switching skb->dev pointer with skb->dev->l3_dev.
>> This is not how we switch netns, nor the way how netns works.
>>
> How it is different from what we are doing currently?
>
> Current: Use skb->dev for L3 processing and derive netns from skb->dev
> Proposal: use skb->dev->l3_dev for L3 processing and derive netns from
> skb->dev->l3_dev


If you ever read the part you quote below, you will have the answer.


>
>> Look at veth pair or dev_change_net_namespace(), each time when we
>> switch netns, we need to do a full reregistration or a full reentrance, we
>> never just switch some pointers to switch netns. This is why I said it breaks
>> isolation.

^ You miss this part.


>>
>> Also, it is ugly to hide such a ipvlan-specific pointer for half of the RX code
>> path.
> I think I have already mentioned, I'm adding RX code now and later
> I'll add TX code to use
> l3_dev to make it symmetric. This way all L3 (Tx/Rx) will use this
> device reference
> always.

You are trying to convince me by telling me you will add more ugly code??
Seriously??
