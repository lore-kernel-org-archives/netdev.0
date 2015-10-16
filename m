From: Insu Yun <wuninsu@gmail.com>
Subject: Re: [PATCH] xen-netback: correctly check failed
	allocation
Date: Fri, 16 Oct 2015 08:48:31 -0400
Message-ID: <CAGoFzNd=StF_jKmi46i7Smc1GvOvpQbCCDE5R5cQkbqWmCMusg@mail.gmail.com>
References: <1444932148-15633-1-git-send-email-wuninsu@gmail.com>
	<CAGoFzNdCef+tutWgabSahHqV0rkC9FdNpjrQEsxk8GMeBA0TKQ@mail.gmail.com>
	<20151016090521.GJ32638@zion.uk.xensource.com>
	<5620C62B.4000001@citrix.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0679819760541274554=="
Cc: Yeongjin Jang <yeongjin.jang@gatech.edu>, Taesoo Kim <taesoo@gatech.edu>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	"Yun, Insu" <insu@gatech.edu>, LKML <linux-kernel@vger.kernel.org>,
	xen-devel@lists.xenproject.org
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <5620C62B.4000001@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

--===============0679819760541274554==
Content-Type: multipart/alternative; boundary=089e01183112841d740522383673

--089e01183112841d740522383673
Content-Type: text/plain; charset=UTF-8

For me, it seems more consistent using xen_bus_dev_fatal(); return;
Because other codes also use them.

If you want to use goto, then feel free to make a patch for this issue.


On Fri, Oct 16, 2015 at 5:40 AM, David Vrabel <david.vrabel@citrix.com>
wrote:

> On 16/10/15 10:05, Wei Liu wrote:
> > On Thu, Oct 15, 2015 at 02:02:47PM -0400, Insu Yun wrote:
> >> I changed patch with valid format.
> >>
> >> On Thu, Oct 15, 2015 at 2:02 PM, Insu Yun <wuninsu@gmail.com> wrote:
> >>
> >>> Since vzalloc can be failed in memory pressure,
> >>> writes -ENOMEM to xenstore to indicate error.
> >>>
> >>> Signed-off-by: Insu Yun <wuninsu@gmail.com>
> >>> ---
> >>>  drivers/net/xen-netback/xenbus.c | 6 ++++++
> >>>  1 file changed, 6 insertions(+)
> >>>
> >>> diff --git a/drivers/net/xen-netback/xenbus.c
> >>> b/drivers/net/xen-netback/xenbus.c
> >>> index 929a6e7..56ebd82 100644
> >>> --- a/drivers/net/xen-netback/xenbus.c
> >>> +++ b/drivers/net/xen-netback/xenbus.c
> >>> @@ -788,6 +788,12 @@ static void connect(struct backend_info *be)
> >>>         /* Use the number of queues requested by the frontend */
> >>>         be->vif->queues = vzalloc(requested_num_queues *
> >>>                                   sizeof(struct xenvif_queue));
> >>> +       if (!be->vif->queues) {
> >>> +               xenbus_dev_fatal(dev, -ENOMEM,
> >>> +                                "allocating queues");
> >>> +               return;
> >>>
> >>
> >> I didn't use goto err, because another error handling is not required
> >>
> >
> > It's recommended in kernel coding style to use "goto" style error
> > handling. I personally prefer that to arbitrary return in function body,
> > too.
> >
> > It's not a matter of whether another error handling is required or not,
> > it's about cleaner code that is easy to reason about and consistent
> > coding style.
>
> Using xenbus_dev_fatal(); return; throughout would be consistent and
> easy to reason about.
>
> Also, the goto err path should raise a fatal error (instead of
> disconnecting).  I also note that failures in the xen_net_read_rate(),
> xen_register_watchers() and read_xenbus_vif_flags() are also not handled.
>
> David
>



-- 
Regards
Insu Yun

--089e01183112841d740522383673
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>For me, it seems more consistent using xen_bus_dev_fa=
tal(); return;</div><div>Because other codes also use them.=C2=A0</div><div=
><br></div><div>If you want to use goto, then feel free to make a patch for=
 this issue.</div><div><br></div><div class=3D"gmail_extra"><br><div class=
=3D"gmail_quote">On Fri, Oct 16, 2015 at 5:40 AM, David Vrabel <span dir=3D=
"ltr">&lt;<a href=3D"mailto:david.vrabel@citrix.com" target=3D"_blank">davi=
d.vrabel@citrix.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quo=
te" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"=
><div class=3D"HOEnZb"><div class=3D"h5">On 16/10/15 10:05, Wei Liu wrote:<=
br>
&gt; On Thu, Oct 15, 2015 at 02:02:47PM -0400, Insu Yun wrote:<br>
&gt;&gt; I changed patch with valid format.<br>
&gt;&gt;<br>
&gt;&gt; On Thu, Oct 15, 2015 at 2:02 PM, Insu Yun &lt;<a href=3D"mailto:wu=
ninsu@gmail.com">wuninsu@gmail.com</a>&gt; wrote:<br>
&gt;&gt;<br>
&gt;&gt;&gt; Since vzalloc can be failed in memory pressure,<br>
&gt;&gt;&gt; writes -ENOMEM to xenstore to indicate error.<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt; Signed-off-by: Insu Yun &lt;<a href=3D"mailto:wuninsu@gmail.co=
m">wuninsu@gmail.com</a>&gt;<br>
&gt;&gt;&gt; ---<br>
&gt;&gt;&gt;=C2=A0 drivers/net/xen-netback/xenbus.c | 6 ++++++<br>
&gt;&gt;&gt;=C2=A0 1 file changed, 6 insertions(+)<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt; diff --git a/drivers/net/xen-netback/xenbus.c<br>
&gt;&gt;&gt; b/drivers/net/xen-netback/xenbus.c<br>
&gt;&gt;&gt; index 929a6e7..56ebd82 100644<br>
&gt;&gt;&gt; --- a/drivers/net/xen-netback/xenbus.c<br>
&gt;&gt;&gt; +++ b/drivers/net/xen-netback/xenbus.c<br>
&gt;&gt;&gt; @@ -788,6 +788,12 @@ static void connect(struct backend_info *=
be)<br>
&gt;&gt;&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Use the number of queues r=
equested by the frontend */<br>
&gt;&gt;&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0be-&gt;vif-&gt;queues =3D vza=
lloc(requested_num_queues *<br>
&gt;&gt;&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sizeof(struct=
 xenvif_queue));<br>
&gt;&gt;&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!be-&gt;vif-&gt;queues) {<br>
&gt;&gt;&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0xenbus=
_dev_fatal(dev, -ENOMEM,<br>
&gt;&gt;&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &quot;allocating queue=
s&quot;);<br>
&gt;&gt;&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return=
;<br>
&gt;&gt;&gt;<br>
&gt;&gt;<br>
&gt;&gt; I didn&#39;t use goto err, because another error handling is not r=
equired<br>
&gt;&gt;<br>
&gt;<br>
&gt; It&#39;s recommended in kernel coding style to use &quot;goto&quot; st=
yle error<br>
&gt; handling. I personally prefer that to arbitrary return in function bod=
y,<br>
&gt; too.<br>
&gt;<br>
&gt; It&#39;s not a matter of whether another error handling is required or=
 not,<br>
&gt; it&#39;s about cleaner code that is easy to reason about and consisten=
t<br>
&gt; coding style.<br>
<br>
</div></div>Using xenbus_dev_fatal(); return; throughout would be consisten=
t and<br>
easy to reason about.<br>
<br>
Also, the goto err path should raise a fatal error (instead of<br>
disconnecting).=C2=A0 I also note that failures in the xen_net_read_rate(),=
<br>
xen_register_watchers() and read_xenbus_vif_flags() are also not handled.<b=
r>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
David<br>
</font></span></blockquote></div><br><br clear=3D"all"><div><br></div>-- <b=
r><div class=3D"gmail_signature"><div>Regards</div>
<div>Insu Yun</div></div>
</div></div>

--089e01183112841d740522383673--


--===============0679819760541274554==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Xen-devel mailing list
Xen-devel@lists.xen.org
http://lists.xen.org/xen-devel

--===============0679819760541274554==--
