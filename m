From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH v2.41 5/5] datapath: Add basic MPLS support to kernel
Date: Wed, 2 Oct 2013 11:03:57 -0700
Message-ID: <CALnjE+qOwkY0NJ=LbT0SgZFmnzvqRHcTS35xWVfMyPtjj4r0ZA@mail.gmail.com>
References: <1380610064-14856-1-git-send-email-horms@verge.net.au>
	<1380610064-14856-6-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>,
	Ben Pfaff <blp@nicira.com>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog135.obsmtp.com ([74.125.149.84]:39047 "HELO
	na3sys009aog135.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754729Ab3JBSD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 14:03:59 -0400
Received: by mail-qc0-f172.google.com with SMTP id l13so803801qcy.31
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 11:03:57 -0700 (PDT)
In-Reply-To: <1380610064-14856-6-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 30, 2013 at 11:47 PM, Simon Horman <horms@verge.net.au> wrote:
> Allow datapath to recognize and extract MPLS labels into flow keys
> and execute actions which push, pop, and set labels on packets.
>
> Based heavily on work by Leo Alterman, Ravi K, Isaku Yamahata and Joe Stringer.
>
> Cc: Ravi K <rkerur@gmail.com>
> Cc: Leo Alterman <lalterman@nicira.com>
> Cc: Isaku Yamahata <yamahata@valinux.co.jp>
> Cc: Joe Stringer <joe@wand.net.nz>
> Signed-off-by: Simon Horman <horms@verge.net.au>
>
> ---
>
> +
> +       /* this hack needed to get regular skb_gso_segment() */
> +#ifdef HAVE___SKB_GSO_SEGMENT
> +#undef __skb_gso_segment
> +       skb_gso = __skb_gso_segment(skb, features, tx_path);
> +#else
> +#undef skb_gso_segment
> +       skb_gso = skb_gso_segment(skb, features);
> +#endif
> +

We can get rid of #ifdefs by just using different name for
rpl___skb_gso_segment(), something like mpls_vlan_skb_gso_segment().
The way it is done for tnl-gso.
