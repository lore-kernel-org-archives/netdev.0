From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] (3/11) netrom - drop buffers in write queue on close
Date: Thu, 14 Aug 2003 14:22:24 -0300
Sender: linux-hams-owner@vger.kernel.org
Message-ID: <20030814172223.GB1785@conectiva.com.br>
References: <20030813153929.3fe71b60.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>,
	Jeroen Vreeken <pe1rxq@amsat.org>, netdev@oss.sgi.com,
	linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030813153929.3fe71b60.shemminger@osdl.org>
List-Id: netdev.vger.kernel.org

Em Wed, Aug 13, 2003 at 03:39:29PM -0700, Stephen Hemminger escreveu:
> From: Jeroen Vreeken <pe1rxq@amsat.org>
> 
> Free buffers in write queue on socket destroy
> 
> diff -Nru a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
> --- a/net/netrom/af_netrom.c	Wed Aug 13 11:58:59 2003
> +++ b/net/netrom/af_netrom.c	Wed Aug 13 11:58:59 2003
> @@ -264,6 +264,9 @@
> +	while ((skb = skb_dequeue(&sk->sk_write_queue)) != NULL) {
> +		kfree_skb(skb);
> +	}

Hey, use skb_queue_purge

- Arnaldo
