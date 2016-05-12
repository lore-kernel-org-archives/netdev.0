From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next PATCH] udp: Resolve NULL pointer dereference
Date: Wed, 11 May 2016 21:29:34 -0700
Message-ID: <CAM_iQpXWWbAKdkngMpE81Snmcam5cFY5JWt-tXSrHQVRU_nggA@mail.gmail.com>
References: <20160512022306.3691.40769.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:33020 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbcELE3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 00:29:54 -0400
Received: by mail-yw0-f175.google.com with SMTP id t10so70702861ywa.0
        for <netdev@vger.kernel.org>; Wed, 11 May 2016 21:29:53 -0700 (PDT)
In-Reply-To: <20160512022306.3691.40769.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 11, 2016 at 7:24 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> While testing an OpenStack configuration using VXLANs I saw the following
> call trace:
...
>
> I believe the trace is pointing to the call to dev_net(dev) in
> udp4_lib_lookup_skb.  If I am not mistaken I believe it is possible for us
> to have skb_dst(skb)->dev be NULL.  So to resolve that I am adding a check
> for this case and skipping the assignment if such an event occurs.

Isn't in this tunneling case skb_dst() should be NULL?
