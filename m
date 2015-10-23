From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 04/11] net: packet: change vnet_hdr_len from int to size_t
Date: Fri, 23 Oct 2015 16:35:02 +0300
Message-ID: <20151023163441-mutt-send-email-mst@redhat.com>
References: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
 <1445602236-24130-5-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: al.drozdov@gmail.com, daniel@iogearbox.net, davem@davemloft.net,
	dwmw2@infradead.org, edumazet@google.com, eyal.birger@gmail.com,
	viro@zeniv.linux.org.uk, willemb@google.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: LABBE Corentin <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1445602236-24130-5-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 23, 2015 at 02:10:29PM +0200, LABBE Corentin wrote:
> vnet_hdr_len cannot be negative and is use in operation/function that
> wait for unsigned value.
> This patch set vnet_hdr_len as size_t.
> 
> Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>

These things need to be done carefully.
I'll look at this next week.

> ---
>  net/packet/af_packet.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index aa4b15c..58a5c8f 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -2632,7 +2632,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
>  	int err, reserve = 0;
>  	struct virtio_net_hdr vnet_hdr = { 0 };
>  	int offset = 0;
> -	int vnet_hdr_len;
> +	size_t vnet_hdr_len;
>  	struct packet_sock *po = pkt_sk(sk);
>  	unsigned short gso_type = 0;
>  	int hlen, tlen;
> @@ -3106,7 +3106,7 @@ static int packet_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
>  	struct sock *sk = sock->sk;
>  	struct sk_buff *skb;
>  	int copied, err;
> -	int vnet_hdr_len = 0;
> +	size_t vnet_hdr_len = 0;
>  	unsigned int origlen = 0;
>  
>  	err = -EINVAL;
> -- 
> 2.4.10
