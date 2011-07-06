From: Gustavo Padovan <padovan@profusion.mobi>
Subject: Re: linux-next: manual merge of the net tree with the
 wireless-current tree
Date: Wed, 6 Jul 2011 08:07:30 -0300
Message-ID: <20110706110730.GA5895@joana>
References: <20110706125329.6e5bdd1a.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110706125329.6e5bdd1a.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Stephen Rothwell <sfr@canb.auug.org.au> [2011-07-06 12:53:29 +1000]:

> Hi all,
> 
> Today's linux-next merge of the net tree got a conflict in
> net/bluetooth/l2cap_core.c between commit 9fa7e4f76f36 ("Bluetooth: Fix
> regression with incoming L2CAP connections") from the wireless-current
> tree and commit 89bc500e41fc ("Bluetooth: Add state tracking to struct
> l2cap_chan") from the net tree.
> 
> I fixed it up (I think - see below) and can carry the fix as necessary.
> -- 
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
> 
> diff --cc net/bluetooth/l2cap_core.c
> index ebff14c,9ec9c8c..0000000
> --- a/net/bluetooth/l2cap_core.c
> +++ b/net/bluetooth/l2cap_core.c
> @@@ -2323,8 -2530,7 +2530,8 @@@ static inline int l2cap_config_req(stru
>   
>   	sk = chan->sk;
>   
> - 	if ((bt_sk(sk)->defer_setup && sk->sk_state != BT_CONNECT2) ||
> - 		 (!bt_sk(sk)->defer_setup && sk->sk_state != BT_CONFIG)) {
>  -	if (chan->state != BT_CONFIG) {
> ++	if ((bt_sk(sk)->defer_setup && chan->state != BT_CONNECT2) ||
> ++		 (!bt_sk(sk)->defer_setup && chan->state != BT_CONFIG)) {

Seems I need to merge my own trees. I'll do that. Thanks, Stephen.
And the fix is right ;)

	Gustavo
