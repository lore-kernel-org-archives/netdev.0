From: Andy Fleming <afleming@gmail.com>
Subject: Re: [RFC][PATCH v4 01/18] Add a new struct for device to manipulate
	external buffer.
Date: Mon, 26 Apr 2010 15:06:29 -0500
Message-ID: <o2j2acbd3e41004261306n4da142bfp4e9a46561dbc8c46@mail.gmail.com>
References: <1272187206-18534-1-git-send-email-xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, jdike@linux.intel.com
To: xiaohui.xin@intel.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1272187206-18534-1-git-send-email-xiaohui.xin@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 25, 2010 at 4:19 AM,  <xiaohui.xin@intel.com> wrote:
> From: Xin Xiaohui <xiaohui.xin@intel.com>
>
> Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
> Signed-off-by: Zhao Yu <yzhao81@gmail.com>
> Reviewed-by: Jeff Dike <jdike@linux.intel.com>
> ---
> =A0include/linux/netdevice.h | =A0 19 ++++++++++++++++++-
> =A01 files changed, 18 insertions(+), 1 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index c79a88b..bf79756 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -530,6 +530,22 @@ struct netdev_queue {
> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 tx_dropped;
> =A0} ____cacheline_aligned_in_smp;
>
> +/* Add a structure in structure net_device, the new field is
> + * named as mp_port. It's for mediate passthru (zero-copy).
> + * It contains the capability for the net device driver,
> + * a socket, and an external buffer creator, external means
> + * skb buffer belongs to the device may not be allocated from
> + * kernel space.
> + */
> +struct mpassthru_port =A0{
> + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 hdr_len;
> + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 data_len;
> + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 npages;
> + =A0 =A0 =A0 unsigned =A0 =A0 =A0 =A0flags;
> + =A0 =A0 =A0 struct socket =A0 *sock;
> + =A0 =A0 =A0 struct skb_external_page *(*ctor)(struct mpassthru_port=
 *,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct =
sk_buff *, int);
> +};


I tried searching around, but couldn't find where struct
skb_external_page is declared.  Where is it?

Andy
