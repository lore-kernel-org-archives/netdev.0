From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH tty-next 15/22] isdn: tty: Use private flag for
 ASYNC_CLOSING
Date: Tue, 17 Jun 2014 12:58:18 +0100
Message-ID: <20140617125818.4f02a760@alan.etchedpixels.co.uk>
References: <1402924639-5164-1-git-send-email-peter@hurleysoftware.com>
	<1402924639-5164-16-git-send-email-peter@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-serial@vger.kernel.org, linux-kernel@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: Peter Hurley <peter@hurleysoftware.com>
Return-path: <linux-serial-owner@vger.kernel.org>
In-Reply-To: <1402924639-5164-16-git-send-email-peter@hurleysoftware.com>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Jun 2014 09:17:12 -0400
Peter Hurley <peter@hurleysoftware.com> wrote:

> ASYNC_CLOSING is no longer used in the tty core; use private flag
> info->closing as substitute.
> 
> CC: Karsten Keil <isdn@linux-pingi.de>
> CC: netdev@vger.kernel.org
> Signed-off-by: Peter Hurley <peter@hurleysoftware.com>
> ---
>  drivers/isdn/i4l/isdn_tty.c | 14 +++++++-------
>  include/linux/isdn.h        |  1 +
>  2 files changed, 8 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/isdn/i4l/isdn_tty.c b/drivers/isdn/i4l/isdn_tty.c
> index 732f68a..5310932 100644
> --- a/drivers/isdn/i4l/isdn_tty.c
> +++ b/drivers/isdn/i4l/isdn_tty.c
> @@ -1577,8 +1577,7 @@ isdn_tty_close(struct tty_struct *tty, struct file *filp)
>  #endif
>  		return;
>  	}
> -	port->flags |= ASYNC_CLOSING;
> -
> +	info->closing = 1;

This is not sane C because

> +  int			closing:1;	 /* port count has dropped to 0    */

has the values 0 and -1.

Using a bool would let the compiler figure out what it wanted to do and
do the right thing. It'll probably generate identical code for most
processors but it gives it the freedom to do better.

Alan
