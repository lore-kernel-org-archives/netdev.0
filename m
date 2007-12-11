From: Dor Laor <dor.laor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH resent] virtio_net: Fix stalled inbound
 trafficon early packets
Date: Tue, 11 Dec 2007 14:48:22 +0200
Message-ID: <475E8716.2010500@qumranet.com>
References: <200712111242.28843.borntraeger@de.ibm.com>
Reply-To: dor.laor-atKUWr5tajBWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1493764913=="
Cc: kvm-devel <kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <200712111242.28843.borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--===============1493764913==
Content-Type: multipart/alternative;
	boundary="------------020407010201000002020105"

This is a multi-part message in MIME format.
--------------020407010201000002020105
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Christian Borntraeger wrote:
>
> Hello Rusty,
>
> while implementing and testing virtio on s390 I found a problem in
> virtio_net: The current virtio_net driver has a startup race, which
> prevents any incoming traffic:
>
> If try_fill_recv submits buffers to the host system data might be
> filled in and an interrupt is sent, before napi_enable finishes.
> In that case the interrupt will kick skb_recv_done which will then
> call netif_rx_schedule. netif_rx_schedule checks, if NAPI_STATE_SCHED
> is set - which is not as we did not run napi_enable. No poll routine
> is scheduled. Furthermore, skb_recv_done returns false, we disables
> interrupts for this device.
>
> One solution is the enable napi before inbound buffer are available.
>
But then you might get recv interrupt without a buffer.
The way other physical NICs doing it is by dis/en/abling interrupt using 
registers (look at e1000).
I suggest we can export add_status and use the original code but
before enabling napi add a call to add_status(dev, VIRTIO_CONFIG_DEV_OPEN).
The host won't trigger an irq until it sees the above.

BTW: Rusty is on vacation and that's probably the reason he didn't respond.
Regards,
Dor.
>
> Signed-off-by: Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/net/virtio_net.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> Index: kvm/drivers/net/virtio_net.c
> ===================================================================
> --- kvm.orig/drivers/net/virtio_net.c
> +++ kvm/drivers/net/virtio_net.c
> @@ -285,13 +285,15 @@ static int virtnet_open(struct net_devic
>  {
>         struct virtnet_info *vi = netdev_priv(dev);
>
> +       napi_enable(&vi->napi);
>         try_fill_recv(vi);
>
>         /* If we didn't even get one input buffer, we're useless. */
> -       if (vi->num == 0)
> +       if (vi->num == 0) {
> +               napi_disable(&vi->napi);
>                 return -ENOMEM;
> +       }
>
> -       napi_enable(&vi->napi);
>         return 0;
>  }
>
>
> -------------------------------------------------------------------------
> SF.Net email is sponsored by:
> Check out the new SourceForge.net Marketplace.
> It's the best place to buy or sell services for
> just about anything Open Source.
> http://sourceforge.net/services/buy/index.php
> _______________________________________________
> kvm-devel mailing list
> kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
> https://lists.sourceforge.net/lists/listinfo/kvm-devel
>


--------------020407010201000002020105
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html;charset=ISO-8859-1" http-equiv="Content-Type">
</head>
<body bgcolor="#ffffff" text="#000000">
Christian Borntraeger wrote:
<blockquote cite="mid:200712111242.28843.borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org"
 type="cite">
  <meta http-equiv="Content-Type" content="text/html; ">
  <meta name="Generator"
 content="MS Exchange Server version 6.5.7652.24">
  <title>[kvm-devel] [PATCH resent] virtio_net: Fix stalled inbound
trafficon early packets</title>
<!-- Converted from text/plain format -->
  <p><font size="2">Hello Rusty,<br>
  <br>
while implementing and testing virtio on s390 I found a problem in<br>
virtio_net: The current virtio_net driver has a startup race, which<br>
prevents any incoming traffic:<br>
  <br>
If try_fill_recv submits buffers to the host system data might be<br>
filled in and an interrupt is sent, before napi_enable finishes.<br>
In that case the interrupt will kick skb_recv_done which will then<br>
call netif_rx_schedule. netif_rx_schedule checks, if NAPI_STATE_SCHED<br>
is set - which is not as we did not run napi_enable. No poll routine<br>
is scheduled. Furthermore, skb_recv_done returns false, we disables<br>
interrupts for this device.<br>
  <br>
One solution is the enable napi before inbound buffer are available.<br>
  <br>
  </font></p>
</blockquote>
But then you might get recv interrupt without a buffer.<br>
The way other physical NICs doing it is by dis/en/abling interrupt
using registers (look at e1000).<br>
I suggest we can export add_status and use the original code but<br>
before enabling napi add a call to add_status(dev, VIRTIO_CONFIG_<font
 size="2">DEV_OPEN).<br>
The host won't trigger an irq until it sees the above.<br>
<br>
BTW: Rusty is on vacation and that's probably the reason he didn't
respond.<br>
Regards,<br>
Dor.<br>
</font>
<blockquote cite="mid:200712111242.28843.borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org"
 type="cite">
  <p><font size="2">Signed-off-by: Christian Borntraeger
<a class="moz-txt-link-rfc2396E" href="mailto:borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org">&lt;borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org&gt;</a><br>
---<br>
&nbsp;drivers/net/virtio_net.c |&nbsp;&nbsp;&nbsp; 6 ++++--<br>
&nbsp;1 file changed, 4 insertions(+), 2 deletions(-)<br>
  <br>
Index: kvm/drivers/net/virtio_net.c<br>
===================================================================<br>
--- kvm.orig/drivers/net/virtio_net.c<br>
+++ kvm/drivers/net/virtio_net.c<br>
@@ -285,13 +285,15 @@ static int virtnet_open(struct net_devic<br>
&nbsp;{<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct virtnet_info *vi = netdev_priv(dev);<br>
  <br>
+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; napi_enable(&amp;vi-&gt;napi);<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; try_fill_recv(vi);<br>
  <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* If we didn't even get one input buffer, we're useless. */<br>
-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (vi-&gt;num == 0)<br>
+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (vi-&gt;num == 0) {<br>
+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; napi_disable(&amp;vi-&gt;napi);<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return -ENOMEM;<br>
+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<br>
  <br>
-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; napi_enable(&amp;vi-&gt;napi);<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return 0;<br>
&nbsp;}<br>
  <br>
  <br>
-------------------------------------------------------------------------<br>
SF.Net email is sponsored by:<br>
Check out the new SourceForge.net Marketplace.<br>
It's the best place to buy or sell services for<br>
just about anything Open Source.<br>
  <a moz-do-not-send="true"
 href="http://sourceforge.net/services/buy/index.php">http://sourceforge.net/services/buy/index.php</a><br>
_______________________________________________<br>
kvm-devel mailing list<br>
<a class="moz-txt-link-abbreviated" href="mailto:kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org">kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org</a><br>
  <a moz-do-not-send="true"
 href="https://lists.sourceforge.net/lists/listinfo/kvm-devel">https://lists.sourceforge.net/lists/listinfo/kvm-devel</a><br>
  </font>
  </p>
</blockquote>
<br>
</body>
</html>

--------------020407010201000002020105--


--===============1493764913==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
--===============1493764913==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
kvm-devel mailing list
kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
https://lists.sourceforge.net/lists/listinfo/kvm-devel

--===============1493764913==--
