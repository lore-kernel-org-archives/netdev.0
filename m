From: Insu Yun <wuninsu@gmail.com>
Subject: Re: [PATCH] xen-netback: correctly check failed
	allocation
Date: Thu, 15 Oct 2015 14:02:47 -0400
Message-ID: <CAGoFzNdCef+tutWgabSahHqV0rkC9FdNpjrQEsxk8GMeBA0TKQ@mail.gmail.com>
References: <1444932148-15633-1-git-send-email-wuninsu@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1330582848383907968=="
Cc: Yeongjin Jang <yeongjin.jang@gatech.edu>, Taesoo Kim <taesoo@gatech.edu>,
	"Yun, Insu" <insu@gatech.edu>, Insu Yun <wuninsu@gmail.com>
To: Ian Campbell <ian.campbell@citrix.com>, Wei Liu <wei.liu2@citrix.com>,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1444932148-15633-1-git-send-email-wuninsu@gmail.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

--===============1330582848383907968==
Content-Type: multipart/alternative; boundary=001a11c25e428ecafb0522287c10

--001a11c25e428ecafb0522287c10
Content-Type: text/plain; charset=UTF-8

I changed patch with valid format.

On Thu, Oct 15, 2015 at 2:02 PM, Insu Yun <wuninsu@gmail.com> wrote:

> Since vzalloc can be failed in memory pressure,
> writes -ENOMEM to xenstore to indicate error.
>
> Signed-off-by: Insu Yun <wuninsu@gmail.com>
> ---
>  drivers/net/xen-netback/xenbus.c | 6 ++++++
>  1 file changed, 6 insertions(+)
>
> diff --git a/drivers/net/xen-netback/xenbus.c
> b/drivers/net/xen-netback/xenbus.c
> index 929a6e7..56ebd82 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -788,6 +788,12 @@ static void connect(struct backend_info *be)
>         /* Use the number of queues requested by the frontend */
>         be->vif->queues = vzalloc(requested_num_queues *
>                                   sizeof(struct xenvif_queue));
> +       if (!be->vif->queues) {
> +               xenbus_dev_fatal(dev, -ENOMEM,
> +                                "allocating queues");
> +               return;
>

I didn't use goto err, because another error handling is not required


> +       }
> +
>         be->vif->num_queues = requested_num_queues;
>         be->vif->stalled_queues = requested_num_queues;
>
> --
> 1.9.1
>
>


-- 
Regards
Insu Yun

--001a11c25e428ecafb0522287c10
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div></div>I changed patch with valid format.<br><div><div=
 class=3D"gmail_extra"><br><div class=3D"gmail_quote">On Thu, Oct 15, 2015 =
at 2:02 PM, Insu Yun <span dir=3D"ltr">&lt;<a href=3D"mailto:wuninsu@gmail.=
com" target=3D"_blank">wuninsu@gmail.com</a>&gt;</span> wrote:<br><blockquo=
te class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc so=
lid;padding-left:1ex">Since vzalloc can be failed in memory pressure,<br>
writes -ENOMEM to xenstore to indicate error.<br>
<br>
Signed-off-by: Insu Yun &lt;<a href=3D"mailto:wuninsu@gmail.com">wuninsu@gm=
ail.com</a>&gt;<br>
---<br>
=C2=A0drivers/net/xen-netback/xenbus.c | 6 ++++++<br>
=C2=A01 file changed, 6 insertions(+)<br>
<br>
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xen=
bus.c<br>
index 929a6e7..56ebd82 100644<br>
--- a/drivers/net/xen-netback/xenbus.c<br>
+++ b/drivers/net/xen-netback/xenbus.c<br>
@@ -788,6 +788,12 @@ static void connect(struct backend_info *be)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Use the number of queues requested by the fr=
ontend */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 be-&gt;vif-&gt;queues =3D vzalloc(requested_num=
_queues *<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sizeof(struct xenvif_queue));=
<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!be-&gt;vif-&gt;queues) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0xenbus_dev_fatal(de=
v, -ENOMEM,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &quot;allocating queues&quot;);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;<br></blockq=
uote><div><br></div><div>I didn&#39;t use goto err, because another error h=
andling is not required<br>=C2=A0</div><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
+=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
+<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 be-&gt;vif-&gt;num_queues =3D requested_num_que=
ues;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 be-&gt;vif-&gt;stalled_queues =3D requested_num=
_queues;<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
1.9.1<br>
<br>
</font></span></blockquote></div><br><br clear=3D"all"><br>-- <br><div clas=
s=3D"gmail_signature"><div>Regards</div>
<div>Insu Yun</div></div>
</div></div></div>

--001a11c25e428ecafb0522287c10--


--===============1330582848383907968==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Xen-devel mailing list
Xen-devel@lists.xen.org
http://lists.xen.org/xen-devel

--===============1330582848383907968==--
