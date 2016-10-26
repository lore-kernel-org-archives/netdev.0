From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/1] driver: tun: Use new macro SOCK_IOC_MAGIC
 instead of literal number 0x89
Date: Wed, 26 Oct 2016 11:12:38 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB020AC7B@AcuExch.aculab.com>
References: <1477400179-32200-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "gfree.wind@gmail.com" <gfree.wind@gmail.com>
To: "'fgao@ikuai8.com'" <fgao@ikuai8.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "jasowang@redhat.com" <jasowang@redhat.com>,
        "edumazet@google.com" <edumazet@google.com>,
        "pabeni@redhat.com" <pabeni@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.187]:63326 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758457AbcJZLPc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 07:15:32 -0400
In-Reply-To: <1477400179-32200-1-git-send-email-fgao@ikuai8.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
> Sent: 25 October 2016 13:56
> The current codes use _IOC_TYPE(cmd) == 0x89 to check if the cmd is one
> socket ioctl command like SIOCGIFHWADDR. But the literal number 0x89 may
> confuse readers. So create one macro SOCK_IOC_MAGIC like SPI_IOC_MAGIC to
> enhance the readability.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  drivers/net/tun.c            | 2 +-
>  include/uapi/linux/sockios.h | 2 ++
>  2 files changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 9328568..9efd185 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1985,7 +1985,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>  	int le;
>  	int ret;
> 
> -	if (cmd == TUNSETIFF || cmd == TUNSETQUEUE || _IOC_TYPE(cmd) == 0x89) {
> +	if (cmd == TUNSETIFF || cmd == TUNSETQUEUE || _IOC_TYPE(cmd) == SOCK_IOC_MAGIC) {
>  		if (copy_from_user(&ifr, argp, ifreq_len))
>  			return -EFAULT;
>  	} else {
> diff --git a/include/uapi/linux/sockios.h b/include/uapi/linux/sockios.h
> index 8e7890b..b8f42f2 100644
> --- a/include/uapi/linux/sockios.h
> +++ b/include/uapi/linux/sockios.h
> @@ -24,6 +24,8 @@
>  #define SIOCINQ		FIONREAD
>  #define SIOCOUTQ	TIOCOUTQ        /* output queue size (not sent + not acked) */
> 
> +#define SOCK_IOC_MAGIC	0x89
> +
>  /* Routing table calls. */
>  #define SIOCADDRT	0x890B		/* add routing table entry	*/
>  #define SIOCDELRT	0x890C		/* delete routing table entry	*/

Shouldn't these constants be defined in terms of SOCK_IOC_MAGIC?
And there must be a better name!

	David
