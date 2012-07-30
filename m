From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net/tun: fix ioctl() based info leaks
Date: Mon, 30 Jul 2012 08:22:20 +0200
Message-ID: <1343629340.2626.13268.camel@edumazet-glaptop>
References: <CAFLxGvwUNxOn3vRLdJeS6hVZ_Oko0_QPZfLWAe+ztCHGdqBFOw@mail.gmail.com>
	 <1343627114-17899-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	richard -rw- weinberger <richard.weinberger@gmail.com>,
	netdev@vger.kernel.org
To: Mathias Krause <minipli@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:65099 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529Ab2G3GW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 02:22:26 -0400
Received: by weyx8 with SMTP id x8so3375530wey.19
        for <netdev@vger.kernel.org>; Sun, 29 Jul 2012 23:22:24 -0700 (PDT)
In-Reply-To: <1343627114-17899-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-30 at 07:45 +0200, Mathias Krause wrote:
> The tun module leaks up to 36 bytes of memory by not fully initializing
> a structure located on the stack that gets copied to user memory by the
> TUNGETIFF and SIOCGIFHWADDR ioctl()s.
> 
> Signed-off-by: Mathias Krause <minipli@googlemail.com>
> ---
> v2:
> - removed braces around else branch
> - minor adjustment of the commit message
> 
>  drivers/net/tun.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 987aeef..01255ff 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1252,9 +1252,11 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>  	int vnet_hdr_sz;
>  	int ret;
>  
> -	if (cmd == TUNSETIFF || _IOC_TYPE(cmd) == 0x89)
> +	if (cmd == TUNSETIFF || _IOC_TYPE(cmd) == 0x89) {
>  		if (copy_from_user(&ifr, argp, ifreq_len))
>  			return -EFAULT;
> +	} else
> +		memset(&ifr, 0, sizeof(ifr));
>  
>  	if (cmd == TUNGETFEATURES) {
>  		/* Currently this just means: "what IFF flags are valid?".


Actually braces were better

vi +169 Documentation/CodingStyle

This does not apply if only one branch of a conditional statement is a
single
statement; in the latter case use braces in both branches:

if (condition) {
        do_this();
        do_that();
} else {
        otherwise();
}
