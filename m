From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH 1/1] net: allow macvlans to move to net namespace
Date: Wed, 17 Sep 2014 13:55:32 -0700
Message-ID: <CAHA+R7OEC2atkP+qb6JoN-Rx7H7sfie+_E_n059GVRGaTYDzww@mail.gmail.com>
References: <20140917181227.09F4E480087@fruggeri-Arora18.sjc.aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Francesco Ruggeri <fruggeri@arista.com>,
	Florian Westphal <fw@strlen.de>,
	chenweilong <chenweilong@huawei.com>,
	David Miller <davem@davemloft.net>
To: Francesco Ruggeri <fruggeri@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:40624 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756162AbaIQUze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 16:55:34 -0400
Received: by mail-lb0-f170.google.com with SMTP id c11so2671875lbj.1
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 13:55:32 -0700 (PDT)
In-Reply-To: <20140917181227.09F4E480087@fruggeri-Arora18.sjc.aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 17, 2014 at 11:12 AM, Francesco Ruggeri
<fruggeri@aristanetworks.com> wrote:
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index a969555..7652fd1 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -806,6 +806,7 @@ static netdev_features_t macvlan_fix_features(struct net_device *dev,
>                                              features,
>                                              mask);
>         features |= ALWAYS_ON_FEATURES;
> +       features &= ~NETIF_F_NETNS_LOCAL;
>
>         return features;
>  }


Even if we have some other way to clear this flag (maybe clearing it
in mask etc.),
explicitly clearing it is more readable, I don't want to spin my head to
read netdev_increment_features(), so,

Acked-by: Cong Wang <cwang@twopensource.com>
