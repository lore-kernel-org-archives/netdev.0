From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost-net: add module alias (v2)
Date: Wed, 11 Jan 2012 20:09:41 +0200
Message-ID: <20120111180941.GA23753@redhat.com>
References: <20120110205400.6c1cb306@nehalam.linuxnetplumber.net>
	<20120111091653.188b24ab@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alan Cox <device@lanana.org>,
	Kay Sievers <kay.sievers@vrfy.org>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20120111091653.188b24ab@nehalam.linuxnetplumber.net>
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

On Wed, Jan 11, 2012 at 09:16:53AM -0800, Stephen Hemminger wrote:
> By adding the correct module alias, programs won't have to explicitly
> call modprobe. Vhost-net will always be available if built into the kernel.
> It does require assigning a permanent minor number for depmod to work.
> Choose one next to TUN since this driver is related to it.
> 
> Also, use C99 style initialization.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

I don't mind but this needs an Ack from Alan Cox
who made it dynamic in the first place,
see 79907d89c397b8bc2e05b347ec94e928ea919d33.

> ---
> v2 - document minor number and make sure to not overlap
> 
>  Documentation/devices.txt  |    2 ++
>  drivers/vhost/net.c        |    8 +++++---
>  include/linux/miscdevice.h |    1 +
>  3 files changed, 8 insertions(+), 3 deletions(-)
> 
> --- a/drivers/vhost/net.c	2012-01-10 10:56:58.883179194 -0800
> +++ b/drivers/vhost/net.c	2012-01-10 19:48:23.650225892 -0800
> @@ -856,9 +856,9 @@ static const struct file_operations vhos
>  };
>  
>  static struct miscdevice vhost_net_misc = {
> -	MISC_DYNAMIC_MINOR,
> -	"vhost-net",
> -	&vhost_net_fops,
> +	.minor = VHOST_NET_MINOR,
> +	.name = "vhost-net",
> +	.fops = &vhost_net_fops,
>  };
>  
>  static int vhost_net_init(void)
> @@ -879,3 +879,5 @@ MODULE_VERSION("0.0.1");
>  MODULE_LICENSE("GPL v2");
>  MODULE_AUTHOR("Michael S. Tsirkin");
>  MODULE_DESCRIPTION("Host kernel accelerator for virtio net");
> +MODULE_ALIAS_MISCDEV(VHOST_NET_MINOR);
> +MODULE_ALIAS("devname:vhost-net");
> --- a/include/linux/miscdevice.h	2012-01-10 10:56:59.779189436 -0800
> +++ b/include/linux/miscdevice.h	2012-01-11 09:13:20.803694316 -0800
> @@ -42,6 +42,7 @@
>  #define AUTOFS_MINOR		235
>  #define MAPPER_CTRL_MINOR	236
>  #define LOOP_CTRL_MINOR		237
> +#define VHOST_NET_MINOR		238
>  #define MISC_DYNAMIC_MINOR	255
>  
>  struct device;
> --- a/Documentation/devices.txt	2012-01-10 10:56:53.399116518 -0800
> +++ b/Documentation/devices.txt	2012-01-11 09:12:49.251197653 -0800
> @@ -447,6 +447,8 @@ Your cooperation is appreciated.
>  		234 = /dev/btrfs-control	Btrfs control device
>  		235 = /dev/autofs	Autofs control device
>  		236 = /dev/mapper/control	Device-Mapper control device
> +		237 = /dev/vhost-net	Host kernel accelerator for virtio net
> +
>  		240-254			Reserved for local use
>  		255			Reserved for MISC_DYNAMIC_MINOR
>  
> 
