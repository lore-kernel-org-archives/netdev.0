From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next PATCH v2] udp: Resolve NULL pointer dereference over
 flow-based vxlan device
Date: Thu, 12 May 2016 13:02:11 -0700
Message-ID: <CAM_iQpWRHAuzFMcQ2=BKuxL8YNt-r0QP8MU0YsTku-i9Km1NUA@mail.gmail.com>
References: <20160512022306.3691.40769.stgit@localhost.localdomain> <20160512195003.26694.17950.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>,
	Jiri Benc <jbenc@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.161.182]:34327 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbcELUCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 16:02:32 -0400
Received: by mail-yw0-f182.google.com with SMTP id j74so83779724ywg.1
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 13:02:31 -0700 (PDT)
In-Reply-To: <20160512195003.26694.17950.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 12, 2016 at 12:51 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> The following trace is seen when receiving a DHCP request over a flow-based
> VXLAN tunnel.  I believe this is caused by the metadata dst having a NULL
> dev value and as a result dev_net(dev) is causing a NULL pointer dereference.
>
> To resolve this I am replacing the check for skb_dst() with skb_valid_dst()
> so that we do not attempt to use the metadata dst to retrieve a device in
> order to determine the network namespace.

Why does UDP layer need to care about tunnel layer things?

If the problem is really what you describe, then the tunnel layer
should reset that dst after finish.
