From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [RFC PATCH 4/5] mlx4: add support for fast rx drop bpf program
Date: Sat, 2 Apr 2016 23:15:38 -0700
Message-ID: <20160403061536.GD21980@gmail.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
 <1459560118-5582-5-git-send-email-bblanco@plumgrid.com>
 <1459562911.6473.299.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, ogerlitz@mellanox.com,
	daniel@iogearbox.net, john.fastabend@gmail.com, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34395 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995AbcDCGPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2016 02:15:42 -0400
Received: by mail-pf0-f173.google.com with SMTP id c20so12368236pfc.1
        for <netdev@vger.kernel.org>; Sat, 02 Apr 2016 23:15:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1459562911.6473.299.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 01, 2016 at 07:08:31PM -0700, Eric Dumazet wrote:
[...]
> 
> 
> 1) mlx4 can use multiple fragments (priv->num_frags) to hold an Ethernet
> frame. 
> 
> Still you pass a single fragment but total 'length' here : BPF program
> can read past the end of this first fragment and panic the box.
> 
> Please take a look at mlx4_en_complete_rx_desc() and you'll see what I
> mean.
Sure, I will do some reading. Jesper also raised the issue after you
did. Please let me know what you think of the proposals.
> 
> 2) priv->stats.rx_dropped is shared by all the RX queues -> false
> sharing.
> 
>    This is probably the right time to add a rx_dropped field in struct
> mlx4_en_rx_ring since you guys want to drop 14 Mpps, and 50 Mpps on
> higher speed links.
> 
This sounds reasonable! Will look into it for the next spin.
