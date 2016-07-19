From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: RE: [PATCH] packet: fix second argument of sock_tx_timestamp()
Date: Tue, 19 Jul 2016 05:24:21 +0000
Message-ID: <HK2PR06MB0548A6D3B4C8D547E11A8C7DD8370@HK2PR06MB0548.apcprd06.prod.outlook.com>
References: <1468905320-8132-1-git-send-email-yoshihiro.shimoda.uh@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "daniel@iogearbox.net" <daniel@iogearbox.net>,
	"willemb@google.com" <willemb@google.com>,
	"ast@plumgrid.com" <ast@plumgrid.com>,
	"tklauser@distanz.ch" <tklauser@distanz.ch>,
	"fruggeri@aristanetworks.com" <fruggeri@aristanetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-renesas-soc@vger.kernel.org"
	<linux-renesas-soc@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1468905320-8132-1-git-send-email-yoshihiro.shimoda.uh@renesas.com>
Content-Language: ja-JP
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Yoshihiro Shimoda
> Sent: Tuesday, July 19, 2016 2:15 PM
> 
> This patch fixes an issue that a syscall (e.g. sendto syscall) cannot
> work correctly. Since the sendto syscall doesn't have msg_control buffer,
> the sock_tx_timestamp() in packet_snd() cannot work correctly because
> the socks.tsflags is set to 0.
> So, this patch sets the socks.tsflags to sk->sk_tsflags as default.
> 
> Fixes: c14ac9451c34 ("sock: enable timestamping using control messages")
> Cc: <stable@vger.kernel.org>
> Reported-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Reported-by: Keita Kobayashi <keita.kobayashi.ym@renesas.com>
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
> ---
>  Changes from v1:
>   - Set socks.tsflags to sk->sk_tsflags as default instead of a condition.
>   - Fix other socks.tsflags values in the af_packet.c.
>   - Revise the commit log.
> 
>  About v1 (as RFC):
>   - http://thread.gmane.org/gmane.linux.kernel.renesas-soc/5646
> 
> 
>  net/packet/af_packet.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 9f0983f..50ea97e 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1927,7 +1927,7 @@ retry:
>  		goto out_unlock;
>  	}
> 
> -	sockc.tsflags = 0;
> +	sockc.tsflags = sk->sk_tsflags;
>  	if (msg->msg_controllen) {
>  		err = sock_cmsg_send(sk, msg, &sockc);
>  		if (unlikely(err)) {
> @@ -2678,7 +2678,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
>  		dev = dev_get_by_index(sock_net(&po->sk), saddr->sll_ifindex);
>  	}
> 
> -	sockc.tsflags = 0;
> +	sockc.tsflags = sk->sk_tsflags;

Oops! I mistook this. I will resubmit a fixed patch

Best regards,
Yoshihiro Shimoda
