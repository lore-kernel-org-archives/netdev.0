From: Andrei Emeltchenko <andrei.emeltchenko.news@gmail.com>
Subject: Re: Resend: [PATCH] Bluetooth: Fix Endian Bug.
Date: Thu, 1 Mar 2012 14:35:42 +0200
Message-ID: <20120301123540.GE25627@aemeltch-MOBL1>
References: <1330599561-20392-1-git-send-email-santoshprasadnayak@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marcel@holtmann.org, padovan@profusion.mobi, davem@davemloft.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: santosh nayak <santoshprasadnayak@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1330599561-20392-1-git-send-email-santoshprasadnayak@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Santosh,

On Thu, Mar 01, 2012 at 04:29:21PM +0530, santosh nayak wrote:
> From: Santosh Nayak <santoshprasadnayak@gmail.com>
> 
> Fix for endian bug.
> 
> Fix for null dereferenced removed as it is already
> submitted by Andrei.
> 
> Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
> ---
>  net/bluetooth/l2cap_sock.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)

We prefer following commit log (this is the example)

<------8<----------------------------------------------------------
|  From: Santosh Nayak <santoshprasadnayak@gmail.com>
|
|  Fix network to host endian conversion for L2CAP chan id.
|
|  Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
|
|  ---
|          * v2 Fix for null dereferenced removed as it is already
|          submitted by Andrei.
|
|    net/bluetooth/l2cap_sock.c |    5 +++--
|    1 files changed, 3 insertions(+), 2 deletions(-)
|
<------8<----------------------------------------------------------


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
>  	else
>  		err = l2cap_add_psm(chan, &la.l2_bdaddr, la.l2_psm);
>  
> @@ -123,7 +123,8 @@ static int l2cap_sock_connect(struct socket *sock, struct sockaddr *addr, int al
>  	if (la.l2_cid && la.l2_psm)
>  		return -EINVAL;
>  
> -	err = l2cap_chan_connect(chan, la.l2_psm, la.l2_cid, &la.l2_bdaddr);
> +	err = l2cap_chan_connect(chan, la.l2_psm, __le16_to_cpu(la.l2_cid),
> +				&la.l2_bdaddr);

I live this to Marcel to decide should we reindent our code otherwise this
one looks odd.

Best regards 
Andrei Emeltchenko 
