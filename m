From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next V3 3/3] tun: rx batching
Date: Sat, 31 Dec 2016 13:03:32 -0800
Message-ID: <20161231130333.347cb8f3@xeon-e3>
References: <1483075251-6889-1-git-send-email-jasowang@redhat.com>
	<1483075251-6889-4-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	wexu@redhat.com, kvm@vger.kernel.org, mst@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1483075251-6889-4-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, 30 Dec 2016 13:20:51 +0800
Jason Wang <jasowang@redhat.com> wrote:

> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index cd8e02c..a268ed9 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -75,6 +75,10 @@
>  
>  #include <linux/uaccess.h>
>  
> +static int rx_batched;
> +module_param(rx_batched, int, 0444);
> +MODULE_PARM_DESC(rx_batched, "Number of packets batched in rx");
> +
>  /* Uncomment to enable debugging */

I like the concept or rx batching. But controlling it via a module parameter
is one of the worst API choices.  Ethtool would be better to use because that is
how other network devices control batching.

If you do ethtool, you could even extend it to have an number of packets
and max latency value.
