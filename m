From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/6] hv_netvsc: avoid races on mtu
 change/set channels
Date: Mon, 16 May 2016 13:27:21 -0400 (EDT)
Message-ID: <20160516.132721.1902162567878052610.davem@davemloft.net>
References: <1463140525-27338-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, haiyangz@microsoft.com,
	kys@microsoft.com, LinoSanfilippo@gmx.de
To: vkuznets@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463140525-27338-1-git-send-email-vkuznets@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vitaly Kuznetsov <vkuznets@redhat.com>
Date: Fri, 13 May 2016 13:55:19 +0200

> Changes since v1:
> - Rebased to net-next [Haiyang Zhang]
> 
> Original description:
> 
> MTU change and set channels operations are implemented as netvsc device
> re-creation destroying internal structures (struct net_device stays). This
> is really unfortunate but there is no support from Hyper-V host to do it
> in a different way. Such re-creation is unsurprisingly racy, Haiyang
> reported a crash when netvsc_change_mtu() is racing with
> netvsc_link_change() but I was able to identify additional races upon
> investigation. Both netvsc_set_channels() and netvsc_change_mtu() race
> against:
> 1) netvsc_link_change()
> 2) netvsc_remove()
> 3) netvsc_send()
> 
> To solve these issues without introducing new locks some refactoring is
> required. We need to get rid of very complex link graph in all the
> internal structures and avoid traveling through structures which are being
> removed.

Series applied, thanks.
