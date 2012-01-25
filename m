From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 1/6] net: pad skb data and shinfo as a whole rather
 than individually
Date: Wed, 25 Jan 2012 13:51:19 +0100
Message-ID: <1327495879.2425.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1327494389.24561.316.camel@zakaz.uk.xensource.com>
	 <1327494434-21566-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:62895 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077Ab2AYMvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 07:51:23 -0500
Received: by wics10 with SMTP id s10so3741056wic.19
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2012 04:51:22 -0800 (PST)
In-Reply-To: <1327494434-21566-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 25 janvier 2012 =C3=A0 12:27 +0000, Ian Campbell a =C3=A9cr=
it :
> This reduces the minimum overhead required for this allocation such t=
hat the
> shinfo can be grown in the following patch without overflowing 2048 b=
ytes for a
> 1500 byte frame.
>=20
> Reducing this overhead while also growing the shinfo means that somet=
imes the
> tail end of the data can end up in the same cache line as the beginni=
ng of the
> shinfo. Specifically in the case of the 64 byte cache lines on a 64 b=
it system
> the first 8 bytes of shinfo can overlap the tail cacheline of the dat=
a. In many
> cases the allocation slop means that there is no overlap.
>=20
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> ---

Hmm... you missed build_skb() and all places we use
SKB_DATA_ALIGN(sizeof(struct skb_shared_info))

(for example in some drivers)

If you want to see possible performance impact of your changes, see
commit e52fcb2462ac (bnx2x: uses build_skb() in receive path), and
expect a drop from 820.000 pps to 720.000 pps
