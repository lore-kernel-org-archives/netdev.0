From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [patch net-next-2.6 1/8] af_packet: use skb->skb_iif instead of orig_dev->ifindex
Date: Sun, 6 Mar 2011 00:34:43 +0800
Message-ID: <AANLkTik=0QVXEyjzLTpez9Re2o85KBeeR+0e=EDuRZxd@mail.gmail.com>
References: <1299313794-5218-1-git-send-email-jpirko@redhat.com> <1299313794-5218-2-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com,
	andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36495 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248Ab1CEQfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 11:35:05 -0500
Received: by fxm17 with SMTP id 17so3018230fxm.19
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2011 08:35:03 -0800 (PST)
In-Reply-To: <1299313794-5218-2-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 5, 2011 at 4:29 PM, Jiri Pirko <jpirko@redhat.com> wrote:
> Since skb_iif has the desired value (ifindex of physical device actually
> received the traffic) use that instead.
>

It isn't true for the packets returned from a ifb pseudo NIC.

f.e.:

eth0 -(redirect)-> ifb0 ->

skb->skb_iff is ifb0->ifindex.
orig_dev = skb->dev = eth0.

However, these packets aren't processed by af_packet, so there isn't
any problem.

Reviewed-by: Changli Gao <xiaosuo@gmail.com>

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
