From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/6] mac802154: Immediately retry
	sending failed packets
Date: Tue, 2 Apr 2013 23:11:38 +0400
Message-ID: <CAJmB2rCr5ds11+iN=W5GCKsUgdfb57uKg+mH4NY4CWw6EFCTbg@mail.gmail.com>
References: <1364928481-1813-1-git-send-email-alan@signal11.us>
	<1364928481-1813-2-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3866357016268961493=="
Cc: "open list:NETWORKING \[GENERAL\]" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-zigbee-devel <linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1364928481-1813-2-git-send-email-alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============3866357016268961493==
Content-Type: multipart/alternative; boundary=20cf301ee52fc5f6b504d965818c

--20cf301ee52fc5f6b504d965818c
Content-Type: text/plain; charset=ISO-8859-1

2013/4/2 Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>

> When ops->xmit() fails, immediately retry. Previously the packet was sent
> to the back of the workqueue.
>
> Signed-off-by: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
> ---
>  net/mac802154/tx.c | 17 ++++++++---------
>  1 file changed, 8 insertions(+), 9 deletions(-)
>
> diff --git a/net/mac802154/tx.c b/net/mac802154/tx.c
> index 4e09d07..fbf937c 100644
> --- a/net/mac802154/tx.c
> +++ b/net/mac802154/tx.c
> @@ -59,19 +59,18 @@ static void mac802154_xmit_worker(struct work_struct
> *work)
>                 }
>         }
>
> -       res = xw->priv->ops->xmit(&xw->priv->hw, xw->skb);
> +       do {
> +               res = xw->priv->ops->xmit(&xw->priv->hw, xw->skb);
> +               if (res && ++xw->xmit_attempts >=
> MAC802154_MAX_XMIT_ATTEMPTS) {
> +                       pr_debug("transmission failed for %d times",
> +                                MAC802154_MAX_XMIT_ATTEMPTS);
> +                       break;
> +               }
> +       } while (res);
>


> IIRC this 802.15.4 stack uses single-thread-work-queue and all RX/TX are
> performed by using it. Doing TX retry in the way you proposed - it's
> possible that you will block other packets pending in this queue. Despite
> on Linux is already 'slow' system to provide real-time for specific
> 802.15.4 features, I think it's not a good idea to increase nodes
> communication latency.
>
>
>  out:
>         mutex_unlock(&xw->priv->phy->pib_lock);
>
> -       if (res) {
> -               if (xw->xmit_attempts++ < MAC802154_MAX_XMIT_ATTEMPTS) {
> -                       queue_work(xw->priv->dev_workqueue, &xw->work);
> -                       return;
> -               } else
> -                       pr_debug("transmission failed for %d times",
> -                                MAC802154_MAX_XMIT_ATTEMPTS);
> -       }
>
>         dev_kfree_skb(xw->skb);
>
> --
> 1.7.11.2
>
>

--20cf301ee52fc5f6b504d965818c
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">2013=
/4/2 Alan Ott <span dir=3D"ltr">&lt;<a href=3D"mailto:alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org" tar=
get=3D"_blank">alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org</a>&gt;</span><br><blockquote class=3D"gmai=
l_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,20=
4,204);padding-left:1ex">
When ops-&gt;xmit() fails, immediately retry. Previously the packet was sen=
t<br>
to the back of the workqueue.<br>
<br>
Signed-off-by: Alan Ott &lt;<a href=3D"mailto:alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org">alan@signal=
11.us</a>&gt;<br>
---<br>
=A0net/mac802154/tx.c | 17 ++++++++---------<br>
=A01 file changed, 8 insertions(+), 9 deletions(-)<br>
<br>
diff --git a/net/mac802154/tx.c b/net/mac802154/tx.c<br>
index 4e09d07..fbf937c 100644<br>
--- a/net/mac802154/tx.c<br>
+++ b/net/mac802154/tx.c<br>
@@ -59,19 +59,18 @@ static void mac802154_xmit_worker(struct work_struct *w=
ork)<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
=A0 =A0 =A0 =A0 }<br>
<br>
- =A0 =A0 =A0 res =3D xw-&gt;priv-&gt;ops-&gt;xmit(&amp;xw-&gt;priv-&gt;hw,=
 xw-&gt;skb);<br>
+ =A0 =A0 =A0 do {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 res =3D xw-&gt;priv-&gt;ops-&gt;xmit(&amp;xw-=
&gt;priv-&gt;hw, xw-&gt;skb);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (res &amp;&amp; ++xw-&gt;xmit_attempts &gt=
;=3D MAC802154_MAX_XMIT_ATTEMPTS) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug(&quot;transmission f=
ailed for %d times&quot;,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0MAC802154_=
MAX_XMIT_ATTEMPTS);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 } while (res);<br>
<div class=3D"gmail_quote"></div></blockquote><div>=A0</div><blockquote cla=
ss=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid =
rgb(204,204,204);padding-left:1ex"><div class=3D"gmail_quote">IIRC this 802=
.15.4 stack uses single-thread-work-queue and all RX/TX are performed by us=
ing it. Doing TX retry in the way you proposed - it&#39;s possible that you=
 will block other packets
 pending in this queue. Despite on Linux is already &#39;slow&#39; system t=
o=20
provide real-time for specific 802.15.4 features, I think it&#39;s not a=20
good idea to increase nodes communication latency. <br></div><br><br>
=A0out:<br>
=A0 =A0 =A0 =A0 mutex_unlock(&amp;xw-&gt;priv-&gt;phy-&gt;pib_lock);<br>
<br>
- =A0 =A0 =A0 if (res) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (xw-&gt;xmit_attempts++ &lt; MAC802154_MAX=
_XMIT_ATTEMPTS) {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 queue_work(xw-&gt;priv-&gt;de=
v_workqueue, &amp;xw-&gt;work);<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug(&quot;transmission f=
ailed for %d times&quot;,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0MAC802154_=
MAX_XMIT_ATTEMPTS);<br>
- =A0 =A0 =A0 }<br>
<br>
=A0 =A0 =A0 =A0 dev_kfree_skb(xw-&gt;skb);<br>
<span class=3D""><font color=3D"#888888"><br>
--<br>
1.7.11.2<br>
<br>
</font></span></blockquote></div><br></div></div>

--20cf301ee52fc5f6b504d965818c--


--===============3866357016268961493==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Minimize network downtime and maximize team effectiveness.
Reduce network management and security costs.Learn how to hire 
the most talented Cisco Certified professionals. Visit the 
Employer Resources Portal
http://www.cisco.com/web/learning/employer_resources/index.html
--===============3866357016268961493==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linux-zigbee-devel mailing list
Linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel

--===============3866357016268961493==--
