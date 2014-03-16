From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] ipv6: ip6_append_data_mtu do not handle the mtu of the second fragment properly
Date: Mon, 17 Mar 2014 00:20:56 +0100
Message-ID: <20140316232056.GD12291@order.stressinduktion.org>
References: <1394945457-16212-1-git-send-email-lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: network dev <netdev@vger.kernel.org>,
	Gao feng <gaofeng@cn.fujitsu.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39634 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755735AbaCPXU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Mar 2014 19:20:58 -0400
Content-Disposition: inline
In-Reply-To: <1394945457-16212-1-git-send-email-lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Sun, Mar 16, 2014 at 12:50:57PM +0800, Xin Long wrote:
> In ip6_append_data_mtu(), when the xfrm mode is not tunnel(such as
> transport),the ipsec header need to be added in the first fragment, so the mtu
> will decrease to reserve space for it, then the second fragment come, the mtu
> should be turn back, as the commit 0c1833797a5a6ec23ea9261d979aa18078720b74
> said.  however, in the commit a493e60ac4bbe2e977e7129d6d8cbb0dd236be, it use
> *mtu = min(*mtu, ...) to change the mtu, which lead to the new mtu is alway
> equal with the first fragment's. and cannot turn back.
> 
> when I test through  ping6 -c1 -s5000 $ip (mtu=1280):
> ...frag (0|1232) ESP(spi=0x00002000,seq=0xb), length 1232
> ...frag (1232|1216)
> ...frag (2448|1216)
> ...frag (3664|1216)
> ...frag (4880|164)
> 
> which should be:
> ...frag (0|1232) ESP(spi=0x00001000,seq=0x1), length 1232
> ...frag (1232|1232)
> ...frag (2464|1232)
> ...frag (3696|1232)
> ...frag (4928|116)
> 
> so delete the min() when change back the mtu.

While the patch looks good it does not seem to apply cleanly on net. Maybe you
could have a look?

Thanks,

  Hannes
