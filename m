From: Amos Kong <kongjianjun@gmail.com>
Subject: Re: [PATCH] vhost-net: add module alias
Date: Wed, 11 Jan 2012 15:43:42 +0800
Message-ID: <CAFeW=paA4Aqk2gy2qpUUM6nANjr3ahio3N02Tz4LVEGVVxNJWA@mail.gmail.com>
References: <20120110205400.6c1cb306@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8662359971306041239=="
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, device@lanana.org,
	alan@linux.intel.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120110205400.6c1cb306@nehalam.linuxnetplumber.net>
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

--===============8662359971306041239==
Content-Type: multipart/alternative; boundary=f46d041826c676865504b63bca49

--f46d041826c676865504b63bca49
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Jan 11, 2012 at 12:54 PM, Stephen Hemminger
<shemminger@vyatta.com>wrote:

> By adding the a module alias, programs (or users) won't have to explicitly
> call modprobe. Vhost-net will always be available if built into the kernel.
> It does require assigning a permanent minor number for depmod to work.
> Choose one next to TUN since this driver is related to it.
>
> Also, use C99 style initialization.
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> ---
>  drivers/vhost/net.c        |    8 +++++---
>  include/linux/miscdevice.h |    1 +
>  2 files changed, 6 insertions(+), 3 deletions(-)
>
> --- a/drivers/vhost/net.c       2012-01-10 10:56:58.883179194 -0800
> +++ b/drivers/vhost/net.c       2012-01-10 19:48:23.650225892 -0800
> @@ -856,9 +856,9 @@ static const struct file_operations vhos
>  };
>
>  static struct miscdevice vhost_net_misc = {
> -       MISC_DYNAMIC_MINOR,
> -       "vhost-net",
> -       &vhost_net_fops,
> +       .minor = VHOST_NET_MINOR,
> +       .name = "vhost-net",
> +       .fops = &vhost_net_fops,
>  };
>
>  static int vhost_net_init(void)
> @@ -879,3 +879,5 @@ MODULE_VERSION("0.0.1");
>  MODULE_LICENSE("GPL v2");
>  MODULE_AUTHOR("Michael S. Tsirkin");
>  MODULE_DESCRIPTION("Host kernel accelerator for virtio net");
> +MODULE_ALIAS_MISCDEV(VHOST_NET_MINOR);
> +MODULE_ALIAS("devname:vhost-net");
> --- a/include/linux/miscdevice.h        2012-01-10 10:56:59.779189436
> -0800
> +++ b/include/linux/miscdevice.h        2012-01-10 19:49:56.091748210
> -0800
> @@ -31,6 +31,7 @@
>  #define I2O_MINOR              166
>  #define MICROCODE_MINOR                184
>  #define TUN_MINOR              200
> +#define VHOST_NET_MINOR                201
>


CC: alan@linux.intel.com
CC: device@lanana.org

include/linux/miscdevice.h:
/*
 *      These allocations are managed by device@lanana.org. If you use an
 *      entry that is not in assigned your entry may well be moved and
 *      reassigned, or set dynamic if a fixed value is not justified.
 */


 #define MWAVE_MINOR            219     /* ACP/Mwave Modem */
>  #define MPT_MINOR              220
>  #define MPT2SAS_MINOR          221
>
> _______________________________________________
> Virtualization mailing list
> Virtualization@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/virtualization
>

--f46d041826c676865504b63bca49
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div class=3D"gmail_quote">On Wed, Jan 11, 2012 at 12:54 PM, Stephen Hemmin=
ger <span dir=3D"ltr">&lt;<a href=3D"mailto:shemminger@vyatta.com">shemming=
er@vyatta.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
By adding the a module alias, programs (or users) won&#39;t have to explici=
tly<br>
call modprobe. Vhost-net will always be available if built into the kernel.=
<br>
It does require assigning a permanent minor number for depmod to work.<br>
Choose one next to TUN since this driver is related to it.<br>
<br>
Also, use C99 style initialization.<br>
<br>
Signed-off-by: Stephen Hemminger &lt;<a href=3D"mailto:shemminger@vyatta.co=
m">shemminger@vyatta.com</a>&gt;<br>
<br>
---<br>
=A0drivers/vhost/net.c =A0 =A0 =A0 =A0| =A0 =A08 +++++---<br>
=A0include/linux/miscdevice.h | =A0 =A01 +<br>
=A02 files changed, 6 insertions(+), 3 deletions(-)<br>
<br>
--- a/drivers/vhost/net.c =A0 =A0 =A0 <a href=3D"tel:2012-01-10%2010" value=
=3D"+12012011010">2012-01-10 10</a>:56:58.883179194 -0800<br>
+++ b/drivers/vhost/net.c =A0 =A0 =A0 <a href=3D"tel:2012-01-10%2019" value=
=3D"+12012011019">2012-01-10 19</a>:48:23.650225892 -0800<br>
@@ -856,9 +856,9 @@ static const struct file_operations vhos<br>
=A0};<br>
<br>
=A0static struct miscdevice vhost_net_misc =3D {<br>
- =A0 =A0 =A0 MISC_DYNAMIC_MINOR,<br>
- =A0 =A0 =A0 &quot;vhost-net&quot;,<br>
- =A0 =A0 =A0 &amp;vhost_net_fops,<br>
+ =A0 =A0 =A0 .minor =3D VHOST_NET_MINOR,<br>
+ =A0 =A0 =A0 .name =3D &quot;vhost-net&quot;,<br>
+ =A0 =A0 =A0 .fops =3D &amp;vhost_net_fops,<br>
=A0};<br>
<br>
=A0static int vhost_net_init(void)<br>
@@ -879,3 +879,5 @@ MODULE_VERSION(&quot;0.0.1&quot;);<br>
=A0MODULE_LICENSE(&quot;GPL v2&quot;);<br>
=A0MODULE_AUTHOR(&quot;Michael S. Tsirkin&quot;);<br>
=A0MODULE_DESCRIPTION(&quot;Host kernel accelerator for virtio net&quot;);<=
br>
+MODULE_ALIAS_MISCDEV(VHOST_NET_MINOR);<br>
+MODULE_ALIAS(&quot;devname:vhost-net&quot;);<br>
--- a/include/linux/miscdevice.h =A0 =A0 =A0 =A0<a href=3D"tel:2012-01-10%2=
010" value=3D"+12012011010">2012-01-10 10</a>:56:59.779189436 -0800<br>
+++ b/include/linux/miscdevice.h =A0 =A0 =A0 =A0<a href=3D"tel:2012-01-10%2=
019" value=3D"+12012011019">2012-01-10 19</a>:49:56.091748210 -0800<br>
@@ -31,6 +31,7 @@<br>
=A0#define I2O_MINOR =A0 =A0 =A0 =A0 =A0 =A0 =A0166<br>
=A0#define MICROCODE_MINOR =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0184<br>
=A0#define TUN_MINOR =A0 =A0 =A0 =A0 =A0 =A0 =A0200<br>
+#define VHOST_NET_MINOR =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0201<br></blockquote=
><div><br><br>CC: <a class=3D"moz-txt-link-abbreviated" href=3D"mailto:alan=
@linux.intel.com">alan@linux.intel.com</a>
<br>CC: <a class=3D"moz-txt-link-abbreviated" href=3D"mailto:device@lanana.=
org">device@lanana.org</a>
<br>
<br>include/linux/miscdevice.h:
<br>/*
<br>=A0*=A0=A0=A0=A0=A0 These allocations are managed by <a class=3D"moz-tx=
t-link-abbreviated" href=3D"mailto:device@lanana.org">device@lanana.org</a>=
. If you use an
<br>=A0*=A0=A0=A0=A0=A0 entry that is not in assigned your entry may well b=
e moved and
<br>=A0*=A0=A0=A0=A0=A0 reassigned, or set dynamic if a fixed value is not =
justified.
<br>=A0*/
<br>=A0
<br><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0pt 0pt 0pt=
 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">
=A0#define MWAVE_MINOR =A0 =A0 =A0 =A0 =A0 =A0219 =A0 =A0 /* ACP/Mwave Mode=
m */<br>
=A0#define MPT_MINOR =A0 =A0 =A0 =A0 =A0 =A0 =A0220<br>
=A0#define MPT2SAS_MINOR =A0 =A0 =A0 =A0 =A0221<br>
<br>
_______________________________________________<br>
Virtualization mailing list<br>
<a href=3D"mailto:Virtualization@lists.linux-foundation.org">Virtualization=
@lists.linux-foundation.org</a><br>
<a href=3D"https://lists.linuxfoundation.org/mailman/listinfo/virtualizatio=
n" target=3D"_blank">https://lists.linuxfoundation.org/mailman/listinfo/vir=
tualization</a><br>
</blockquote></div><br>

--f46d041826c676865504b63bca49--

--===============8662359971306041239==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============8662359971306041239==--
