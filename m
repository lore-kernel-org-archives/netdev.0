From: Insu Yun <wuninsu@gmail.com>
Subject: Re: [PATCH] xen-netback: corretly check failed
	allocation
Date: Thu, 15 Oct 2015 13:27:29 -0400
Message-ID: <CAGoFzNcYu4-07pnJR-N3HV8mv-wDqYtJJAhiZY1M7ZL7tVu4vA@mail.gmail.com>
References: <1444926376-29211-1-git-send-email-wuninsu@gmail.com>
	<20151015171301.GB5541@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8769871204652781959=="
Cc: Yeongjin Jang <yeongjin.jang@gatech.edu>, Taesoo Kim <taesoo@gatech.edu>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	"Yun, Insu" <insu@gatech.edu>, linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <20151015171301.GB5541@zion.uk.xensource.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

--===============8769871204652781959==
Content-Type: multipart/alternative; boundary=047d7b8738685334ac052227fef4

--047d7b8738685334ac052227fef4
Content-Type: text/plain; charset=UTF-8

Sorry for wrong format, I forgot to change my configuration.

On Thu, Oct 15, 2015 at 1:13 PM, Wei Liu <wei.liu2@citrix.com> wrote:

> On Thu, Oct 15, 2015 at 12:26:16PM -0400, Insu Yun wrote:
> > Since vzalloc can be failed in memory pressure,
> > return value should be checked and return ENOMEM.
>
> This function doesn't return ENOMEM, instead it writes to xenstore to
> indicate error. The commit log needs to be updated.
>
>
Good. I will update it.


> >
> > Signed-off-by: Insu Yun <wuninsu@gmail.com>
> > ---
> >  drivers/net/xen-netback/xenbus.c | 5 +++++
> >  1 file changed, 5 insertions(+)
> >
> > diff --git a/drivers/net/xen-netback/xenbus.c
> b/drivers/net/xen-netback/xenbus.c
> > index 929a6e7..e288246 100644
> > --- a/drivers/net/xen-netback/xenbus.c
> > +++ b/drivers/net/xen-netback/xenbus.c
> > @@ -788,6 +788,11 @@ static void connect(struct backend_info *be)
> >       /* Use the number of queues requested by the frontend */
> >       be->vif->queues = vzalloc(requested_num_queues *
> >                                 sizeof(struct xenvif_queue));
> > +  if (!be->vif->queues)  {
> > +    xenbus_dev_fatal(dev, -ENOMEM, "allocating queues");
> > +    return;
> > +  }
> > +
>
> The indentation is wrong. Please configure your email client properly.
>
> And please use "goto err" for error handling -- yes, I understand there
> is existing code that returns directly but IMHO that should be fixed
> too.
>
>
Ok. Actually I made a code referring the existing code.


> We.
>
> >       be->vif->num_queues = requested_num_queues;
> >       be->vif->stalled_queues = requested_num_queues;
> >
> > --
> > 1.9.1
>



-- 
Regards
Insu Yun

--047d7b8738685334ac052227fef4
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Sorry for wrong format, I forgot to change my configu=
ration.<br></div><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">=
On Thu, Oct 15, 2015 at 1:13 PM, Wei Liu <span dir=3D"ltr">&lt;<a href=3D"m=
ailto:wei.liu2@citrix.com" target=3D"_blank">wei.liu2@citrix.com</a>&gt;</s=
pan> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex=
;border-left:1px #ccc solid;padding-left:1ex"><span class=3D"">On Thu, Oct =
15, 2015 at 12:26:16PM -0400, Insu Yun wrote:<br>
&gt; Since vzalloc can be failed in memory pressure,<br>
&gt; return value should be checked and return ENOMEM.<br>
<br>
</span>This function doesn&#39;t return ENOMEM, instead it writes to xensto=
re to<br>
indicate error. The commit log needs to be updated.<br>
<span class=3D""><br></span></blockquote><div><br></div><div>Good. I will u=
pdate it.<br></div><div>=C2=A0</div><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><span cl=
ass=3D"">
&gt;<br>
&gt; Signed-off-by: Insu Yun &lt;<a href=3D"mailto:wuninsu@gmail.com">wunin=
su@gmail.com</a>&gt;<br>
&gt; ---<br>
&gt;=C2=A0 drivers/net/xen-netback/xenbus.c | 5 +++++<br>
&gt;=C2=A0 1 file changed, 5 insertions(+)<br>
&gt;<br>
&gt; diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netbac=
k/xenbus.c<br>
&gt; index 929a6e7..e288246 100644<br>
&gt; --- a/drivers/net/xen-netback/xenbus.c<br>
&gt; +++ b/drivers/net/xen-netback/xenbus.c<br>
&gt; @@ -788,6 +788,11 @@ static void connect(struct backend_info *be)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0/* Use the number of queues requested by the=
 frontend */<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0be-&gt;vif-&gt;queues =3D vzalloc(requested_=
num_queues *<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sizeof(struct xenvif_queue)=
);<br>
&gt; +=C2=A0 if (!be-&gt;vif-&gt;queues)=C2=A0 {<br>
&gt; +=C2=A0 =C2=A0 xenbus_dev_fatal(dev, -ENOMEM, &quot;allocating queues&=
quot;);<br>
&gt; +=C2=A0 =C2=A0 return;<br>
&gt; +=C2=A0 }<br>
&gt; +<br>
<br>
</span>The indentation is wrong. Please configure your email client properl=
y.<br>
<br>
And please use &quot;goto err&quot; for error handling -- yes, I understand=
 there<br>
is existing code that returns directly but IMHO that should be fixed<br>
too.<br>
<br></blockquote><div><br></div><div>Ok. Actually I made a code referring t=
he existing code.<br></div><div>=C2=A0</div><blockquote class=3D"gmail_quot=
e" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
We.<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0be-&gt;vif-&gt;num_queues =3D requested_num_=
queues;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0be-&gt;vif-&gt;stalled_queues =3D requested_=
num_queues;<br>
&gt;<br>
&gt; --<br>
&gt; 1.9.1<br>
</div></div></blockquote></div><br><br clear=3D"all"><br>-- <br><div class=
=3D"gmail_signature"><div>Regards</div>
<div>Insu Yun</div></div>
</div></div>

--047d7b8738685334ac052227fef4--


--===============8769871204652781959==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Xen-devel mailing list
Xen-devel@lists.xen.org
http://lists.xen.org/xen-devel

--===============8769871204652781959==--
