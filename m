From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 14/18] net: usb: use wrapper functions of net_ratelimit()
 to simplify code
Date: Tue, 15 Oct 2013 23:06:04 +0400
Message-ID: <525D921C.2030709@cogentembedded.com>
References: <1381837514-50660-1-git-send-email-wangkefeng.wang@huawei.com> <1381837514-50660-15-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Samuel Ortiz <samuel@sortiz.org>,
	Paul Mackerras <paulus@samba.org>,
	Oliver Neukum <oneukum@suse.de>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>, netfilter@vger.kernel
To: Kefeng Wang <wangkefeng.wang@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381837514-50660-15-git-send-email-wangkefeng.wang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 10/15/2013 03:45 PM, Kefeng Wang wrote:

> net_ratelimited_function() is called to simplify code.

> Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
> ---
>   drivers/net/usb/usbnet.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)

> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index bf94e10..edf81de 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -450,8 +450,8 @@ void usbnet_defer_kevent (struct usbnet *dev, int work)
>   {
>   	set_bit (work, &dev->flags);
>   	if (!schedule_work (&dev->kevent)) {
> -		if (net_ratelimit())
> -			netdev_err(dev->net, "kevent %d may have been dropped\n", work);
> +		net_ratelimited_function(netdev_err, dev->net,
> +			"kevent %d may have been dropped\n", work);

    The continuation line should start under 'netdev_err'. Same about the 
other patches where you didn't change the indentation of the continuation 
lines though you should have.

WBR, Sergei
