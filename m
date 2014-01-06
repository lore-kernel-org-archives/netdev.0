From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V1 net-next 2/2] net: Add UDP GRO support for vxlan traffic
Date: Mon, 6 Jan 2014 20:13:45 +0200
Message-ID: <CAJZOPZKfxws+S3ZtTqKQ_yXYhoV=UTOXscM+rVB24UA2d1Fopg@mail.gmail.com>
References: <1388935422-7331-1-git-send-email-ogerlitz@mellanox.com>
	<1388935422-7331-3-git-send-email-ogerlitz@mellanox.com>
	<CA+mtBx-g1tsBEG6D0oOmG-J_fz68fr6py2OY6RAtoJHUts7h3g@mail.gmail.com>
	<CAJZOPZJ2DRP13LRzcu__rh=JxY7oAvCQ37dCpmO40ptiRn5hFw@mail.gmail.com>
	<CAJZOPZLZNEvao9PxtX78sfpg_4GVamgxNMNU52QQ1aFqAxQDZA@mail.gmail.com>
	<CA+mtBx_B+7CU3GDiod+n7tHfwBcA_3DEhD7tvPYhsZMebiwY8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>, Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:50401 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755282AbaAFSNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 13:13:46 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so18719873pab.6
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 10:13:45 -0800 (PST)
In-Reply-To: <CA+mtBx_B+7CU3GDiod+n7tHfwBcA_3DEhD7tvPYhsZMebiwY8w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 6, 2014 at 6:50 PM, Tom Herbert <therbert@google.com> wrote:
> I think this would be a good start. We can further optimize the encap
> path later on.

good, did you had the chance to look on the 2nd problem I was facing,
e.g how to prevent gro-ing encapsulated VM (this issue will not happen
for non-virtualization schemes, I think) udp packets which happen to
carry a destination port which belongs to an encapsulation protocol?
as I wrote earlier here, I was thinking to add some field to struct
napi_gro_cb which will be zeroed when the gro stacks starts to work on
the skb and set once we pass udp_gro_receive, such that if we arrive
again to udp_gro_recieve and this field is set, which means the
encapsulated
packet is udp one, we flush.
