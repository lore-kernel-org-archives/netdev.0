From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] vhost-net: add module alias (v2)
Date: Wed, 11 Jan 2012 21:00:17 +0000
Message-ID: <1326315617.2705.10.camel@bwh-desktop>
References: <20120110205400.6c1cb306@nehalam.linuxnetplumber.net>
	<20120111091653.188b24ab@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, Kay Sievers <kay.sievers@vrfy.org>,
	virtualization@lists.linux-foundation.org, Alan Cox <device@lanana.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

On Wed, 2012-01-11 at 09:16 -0800, Stephen Hemminger wrote:
> By adding the correct module alias, programs won't have to explicitly
> call modprobe. Vhost-net will always be available if built into the kernel.
> It does require assigning a permanent minor number for depmod to work.
> Choose one next to TUN since this driver is related to it.
> 
> Also, use C99 style initialization.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> v2 - document minor number and make sure to not overlap
[...]
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
[...]

238 != 237.  It looks like someone forgot to add loopctrl here.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
