From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] core/dev: do not ignore dmac in dev_forward_skb()
Date: Tue, 12 Nov 2013 09:49:29 +0100
Message-ID: <5281EB99.5000104@6wind.com>
References: <1384206735-4226-1-git-send-email-ast@plumgrid.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Maciej Zenczykowski <zenczykowski@gmail.com>
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:40537 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964Ab3KLItc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 03:49:32 -0500
Received: by mail-we0-f171.google.com with SMTP id t61so2292488wes.16
        for <netdev@vger.kernel.org>; Tue, 12 Nov 2013 00:49:31 -0800 (PST)
In-Reply-To: <1384206735-4226-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/11/2013 22:52, Alexei Starovoitov a =C3=A9crit :
> commit 06a23fe31ca3
> ("core/dev: set pkt_type after eth_type_trans() in dev_forward_skb()"=
)
> and refactoring 64261f230a91
> ("dev: move skb_scrub_packet() after eth_type_trans()")
>
> are forcing pkt_type to be PACKET_HOST when skb traverses veth.
>
> which means that ip forwarding will kick in inside netns
> even if skb->eth->h_dest !=3D dev->dev_addr
>
> Revert offending commit
>
> Fixes: 06a23fe31ca3 ("core/dev: set pkt_type after eth_type_trans() i=
n dev_forward_skb()")
> CC: Maciej Zenczykowski <zenczykowski@gmail.com>
> CC: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
skb_scrub_packet() is also called after eth_type_trans() in ip_tunnel_r=
cv().
I do it to be consistent with dev_forward_skb(), thus it should be inve=
rted too.
