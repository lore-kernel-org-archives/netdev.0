From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH -resend 1/6] mISDN: Add support for group membership check
Date: Wed, 22 May 2013 23:04:20 +0400
Message-ID: <519D16B4.7080905@cogentembedded.com>
References: <1369227552-11743-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jirislaby@gmail.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, Jeff Mahoney <jeffm@suse.com>,
	Patrick Koppen <isdn4linux@koppen.de>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369227552-11743-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 22-05-2013 16:59, Jiri Slaby wrote:

> From: Jeff Mahoney <jeffm@suse.com>

> This patch adds a module parameter to allow a group access to the
> mISDN devices. Otherwise, unpriviledged users on systems with ISDN
> hardware have the ability to dial out, potentially causing expensive
> bills.

> Based on a different implementation by Patrick Koppen <isdn4linux@koppen.de>

> Acked-by: Jeff Mahoney <jeffm@suse.com>
> Cc: Patrick Koppen <isdn4linux@koppen.de>
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Cc: Karsten Keil <isdn@linux-pingi.de>
> Cc: netdev@vger.kernel.org
> Cc: "David S. Miller" <davem@davemloft.net>
> ---
>   drivers/isdn/mISDN/core.c   | 3 +++
>   drivers/isdn/mISDN/core.h   | 1 +
>   drivers/isdn/mISDN/socket.c | 8 ++++++++
>   3 files changed, 12 insertions(+)

[...]
> diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
> index e47dcb9..71f4986 100644
> --- a/drivers/isdn/mISDN/socket.c
> +++ b/drivers/isdn/mISDN/socket.c
> @@ -612,6 +612,10 @@ data_sock_create(struct net *net, struct socket *sock, int protocol)
>   {
>   	struct sock *sk;
>
> +	if(!capable(CAP_SYS_ADMIN) && (misdn_permitted_gid != current_gid())

     Did you run this thru scripts/checkpatch.pl? There should be space 
after *if*. Also, () around != are not neccessary...

> @@ -694,6 +698,10 @@ base_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
>   	case IMSETDEVNAME:
>   	{
>   		struct mISDN_devrename dn;
> +		if(!capable(CAP_SYS_ADMIN)

    Again, need space after *if*.

> +			&& (misdn_permitted_gid != current_gid())

    Better leave && on a previous line and align the line under !. () 
again are not necessary.

> +			&& (!in_group_p(misdn_permitted_gid)))

    () around !x are simply not needed -- ! operator has very high priority.

WBR, Sergei
