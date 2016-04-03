From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [RFC PATCH 0/5] Add driver bpf hook for early packet drop
Date: Sat, 2 Apr 2016 22:41:04 -0700
Message-ID: <20160403054103.GB21980@gmail.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
 <CALx6S37y8+kFh=04cceSpLWZMHkanwWREgoVKc7Edmyhe3qvzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	gerlitz@mellanox.com, Daniel Borkmann <daniel@iogearbox.net>,
	john fastabend <john.fastabend@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34429 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751873AbcDCFlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2016 01:41:08 -0400
Received: by mail-pa0-f54.google.com with SMTP id fe3so120829214pab.1
        for <netdev@vger.kernel.org>; Sat, 02 Apr 2016 22:41:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S37y8+kFh=04cceSpLWZMHkanwWREgoVKc7Edmyhe3qvzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 02, 2016 at 12:47:16PM -0400, Tom Herbert wrote:
> Very nice! Do you think this hook will be sufficient to implement a
> fast forward patch also?
That is the goal, but more work needs to be done of course. It won't be
possible with just a single pseudo skb, the driver will need a fast way to get
batches of pseudo skbs (per core?) through from rx to tx. In mlx4 for
instance, either the skb needs to be much more complete to be handled from the
start of mlx4_en_xmit(), or that function would need to be split so that the
fast tx could start midway through.

Or, skb allocation just gets much faster. Then it should be pretty
straightforward.
> 
> Tom
