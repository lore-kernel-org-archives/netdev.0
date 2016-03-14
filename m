From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 08/13] net/mlx5e: Add fragmented memory support
 for RX multi packet WQE
Date: Mon, 14 Mar 2016 13:29:46 -0700
Message-ID: <1457987386.31401.11.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
	 <1457703594-9482-9-git-send-email-saeedm@mellanox.com>
	 <1457706771.2663.37.camel@edumazet-ThinkPad-T530>
	 <CALzJLG_XU-KMp8dMqcNOpu1OxZRnJro4LFQohK=FLX+5uJKXpQ@mail.gmail.com>
	 <1457726319.2663.50.camel@edumazet-ThinkPad-T530>
	 <CALzJLG9rB4iBnOC0f+8NopjdS407-WJ9b7KFUPO9hjbwFCyP-A@mail.gmail.com>
	 <CAEHy93JgcwKFRK+6ZVXgee77N6h+QbBNoAhE61sd0t6-0dnE1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: achiad shochat <achiad.mellanox@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34501 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753263AbcCNU3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 16:29:48 -0400
Received: by mail-pf0-f169.google.com with SMTP id x3so49739392pfb.1
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 13:29:48 -0700 (PDT)
In-Reply-To: <CAEHy93JgcwKFRK+6ZVXgee77N6h+QbBNoAhE61sd0t6-0dnE1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-03-14 at 21:16 +0200, achiad shochat wrote:

> I really do not see why the new scheme is more DOSable than the common
> scheme of pre-allocating SKB using napi_alloc_skb().

Because sizeof(skb_shared_info) is big enough that if you allocate 128
bytes, you end up using 512 bytes or even more.

In practice it is good enough.
