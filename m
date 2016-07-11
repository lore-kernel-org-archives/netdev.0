From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [net-next PATCH RFC] mlx4: RX prefetch loop
Date: Mon, 11 Jul 2016 09:00:56 -0700
Message-ID: <20160711160054.GA22729@gmail.com>
References: <20160708172024.4a849b7a@redhat.com>
 <20160708160135.27507.77711.stgit@firesoul>
 <20160711130922.636ee4e6@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kafai@fb.com, daniel@iogearbox.net,
	tom@herbertland.com, john.fastabend@gmail.com,
	gerlitz.or@gmail.com, hannes@stressinduktion.org,
	rana.shahot@gmail.com, tgraf@suug.ch,
	"David S. Miller" <davem@davemloft.net>, as754m@att.com,
	saeedm@mellanox.com, amira@mellanox.com, tzahio@mellanox.com,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35015 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755085AbcGKQBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 12:01:00 -0400
Received: by mail-pf0-f173.google.com with SMTP id c2so37714913pfa.2
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 09:00:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160711130922.636ee4e6@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2016 at 01:09:22PM +0200, Jesper Dangaard Brouer wrote:
[...]
> This patch is based on top of Brenden's patch 11/12, and is mean to
> replace patch 12/12.
> 
> Prefetching is very important for XDP, especially when using a CPU
> without DDIO (here i7-4790K CPU @ 4.00GHz).
> 
> Program xdp1: touching-data and dropping packets:
>  * 11,363,925 pkt/s == no-prefetch
>  * 21,031,096 pkt/s == brenden's-prefetch
>  * 21,062,728 pkt/s == this-prefetch-patch
> 
> Program xdp2: write-data (swap src_dst_mac) TX-bounce out same interface:
>  *  6,726,482 pkt/s == no-prefetch
>  * 10,378,163 pkt/s == brenden's-prefetch
>  * 10,622,350 pkt/s == this-prefetch-patch
> 
I see the same XDP numbers in my setup with this patch as well.

[...]
