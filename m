From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net-next 3/6] qed/qede: Add VXLAN tunnel slowpath
 configuration support
Date: Sat, 9 Apr 2016 13:29:38 -0300
Message-ID: <CAEh+42g4+=UT95B5gyW4RZ+yqKAABxaE4SoDEA2f6OKiUSNGcA@mail.gmail.com>
References: <1460207825-3622-1-git-send-email-manish.chopra@qlogic.com> <1460207825-3622-4-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Ariel.Elior@qlogic.com, Yuval.Mintz@qlogic.com
To: Manish Chopra <manish.chopra@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:58680 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753393AbcDIQ34 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Apr 2016 12:29:56 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 664E8202B8
	for <netdev@vger.kernel.org>; Sat,  9 Apr 2016 16:29:54 +0000 (UTC)
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 91A7220260
	for <netdev@vger.kernel.org>; Sat,  9 Apr 2016 16:29:53 +0000 (UTC)
Received: by mail-qg0-f50.google.com with SMTP id f52so113950922qga.3
        for <netdev@vger.kernel.org>; Sat, 09 Apr 2016 09:29:53 -0700 (PDT)
In-Reply-To: <1460207825-3622-4-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 9, 2016 at 10:17 AM, Manish Chopra <manish.chopra@qlogic.com> wrote:
> diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
> index 518af32..9a82d42 100644
> --- a/drivers/net/ethernet/qlogic/qede/qede_main.c
> +++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
[...]
> +static netdev_features_t qede_features_check(struct sk_buff *skb,
> +                                            struct net_device *dev,
> +                                            netdev_features_t features)
> +{
> +       return vxlan_features_check(skb, features);
> +}

This is going to restrict the set of protocols that can be offloaded
to those that look exactly like VXLAN. In particular, it means that
you won't be able offload Geneve with options. I don't think this what
you mean to do given that you are supporting these protocols in the
other patches and I know this hardware has more capabilities than just
VXLAN. I think that you want to do a header length check - similar to
what the Intel drivers are doing for example.

I noticed that the bnx2x driver has a similar issue as well.
