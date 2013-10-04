From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] veth: Showing peer of veth type dev in ip link (kernel
 side)
Date: Thu, 03 Oct 2013 21:49:00 -0700
Message-ID: <1380862140.3564.3.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380859529-32351-1-git-send-email-yamato@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Masatake YAMATO <yamato@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:39049 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861Ab3JDEtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 00:49:07 -0400
Received: by mail-pa0-f41.google.com with SMTP id bj1so3615472pad.0
        for <netdev@vger.kernel.org>; Thu, 03 Oct 2013 21:49:06 -0700 (PDT)
In-Reply-To: <1380859529-32351-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-04 at 13:05 +0900, Masatake YAMATO wrote:
> ip link has ability to show extra information of net work device if
> kernel provides sunh information. With this patch veth driver can
> provide its peer ifindex information to ip command via netlink
> interface.

> +
> +	peer_ifindex = peer ? peer->ifindex : 0;
> +	if (nla_put_u64(skb, VETH_INFO_PEER, peer_ifindex))
> +		return -EMSGSIZE;
> +

ifindex are int, so you should use nla_put_u32()
