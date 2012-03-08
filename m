From: Gustavo Padovan <padovan@profusion.mobi>
Subject: Re: Resend: [PATCH] Bluetooth: Fix Endian Bug.
Date: Thu, 8 Mar 2012 02:33:21 -0300
Message-ID: <20120308053320.GD3998@joana>
References: <1330622196-12967-1-git-send-email-santoshprasadnayak@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marcel@holtmann.org, davem@davemloft.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: santosh nayak <santoshprasadnayak@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1330622196-12967-1-git-send-email-santoshprasadnayak@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Santosh,

* santosh nayak <santoshprasadnayak@gmail.com> [2012-03-01 22:46:36 +0530]:

> From: Santosh Nayak <santoshprasadnayak@gmail.com>
> 
> Fix network to host endian conversion for L2CAP chan id.
> 
> Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
> ---
>  net/bluetooth/l2cap_sock.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
> index 401d942..86d5067 100644
> --- a/net/bluetooth/l2cap_sock.c
> +++ b/net/bluetooth/l2cap_sock.c
> @@ -82,7 +82,7 @@ static int l2cap_sock_bind(struct socket *sock, struct sockaddr *addr, int alen)
>  	}
>  
>  	if (la.l2_cid)
> -		err = l2cap_add_scid(chan, la.l2_cid);
> +		err = l2cap_add_scid(chan, __le16_to_cpu(la.l2_cid));

This is kind weird, la.l2_cid comes from the user, so it is already in host
endian. No need for convertions here.

	Gustavo
