From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2.57] datapath: Add basic MPLS support to
	kernel
Date: Wed, 21 May 2014 16:53:37 -0700
Message-ID: <CAEP_g=9RrFfyj2_C3QG9oBgjoY36-3+Ck6At=o5mt_ysb1TPqQ@mail.gmail.com>
References: <1400195227-21265-1-git-send-email-horms@verge.net.au>
 <1400195227-21265-2-git-send-email-horms@verge.net.au>
 <CAEP_g=8ZEbx0NzCaXOc=ywiBAtejpmO4K-UzVk5uwBmEfUwZ7w@mail.gmail.com>
 <20140521153153.GB10390@verge.net.au>
 <CAEP_g=9At8jhM2ym31YeWaC9u6_O-Sq1igpER3TuYXj=KXTJNg@mail.gmail.com>
 <20140521230351.GC19986@verge.net.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2038334637057180332=="
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140521230351.GC19986-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

--===============2038334637057180332==
Content-Type: multipart/alternative; boundary=001a11c2c6f68121c404f9f1b42b

--001a11c2c6f68121c404f9f1b42b
Content-Type: text/plain; charset=UTF-8

On Wednesday, May 21, 2014, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:

> On Wed, May 21, 2014 at 01:31:55PM -0700, Jesse Gross wrote:
> > On Wed, May 21, 2014 at 8:31 AM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org<javascript:;>>
> wrote:
> > > On Tue, May 20, 2014 at 07:30:38PM -0700, Jesse Gross wrote:
> > >> On Thu, May 15, 2014 at 4:07 PM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org<javascript:;>>
> wrote:
> > >> > diff --git a/datapath/linux/compat/include/linux/netdevice.h
> b/datapath/linux/compat/include/linux/netdevice.h
> > >> > index d726390..0381002 100644
> > >> > --- a/datapath/linux/compat/include/linux/netdevice.h
> > >> > +++ b/datapath/linux/compat/include/linux/netdevice.h
> > >> > +#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,38)
> > >> >  #define netif_skb_features rpl_netif_skb_features
> > >> >  netdev_features_t rpl_netif_skb_features(struct sk_buff *skb);
> > >>
> > >> Currently this function doesn't look at mpls_features. Should it for
> > >> things other than TSO?
> > >
> > > It seems to me that rpl_netif_skb_features is only used by
> > > rpl_dev_queue_xmit().
> > >
> > > If that is the case then I don't think it is necessary to examine
> > > mpls_features, which was introduced in v3.11, as rpl_dev_queue_xmit()
> > > only exists for older kernel versions.
> >
> > Sorry, I actually meant for upstream. I agree that the compatibility
> > code reflects current kernels as written.
> >
> > It seems like the checks in dev_hard_start_xmit() won't take
> > mpls_features (or the presence of MPLS) into account when deciding
> > whether to emulate the offload or pass the skb directly to the NIC. In
> > the GSO code itself, we look at mpls_features but if we never get
> > there then it will be too late.
>
> I am reasonably sure that when I merged the MPLS GSO code into mainline
> that it worked for the case where a non-MPLS GSO packet became an MPLS GSO
> packet (due to a push MPLS action). But that was a while ago and looking
> over the code its not obvious to my why that case would work.
>
> I'll do some testing an analysis and propose a fix if necessary.
>
> Would that address your concern?
>

Yes, that's fine.

--001a11c2c6f68121c404f9f1b42b
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Wednesday, May 21, 2014, Simon Horman &lt;<a href=3D"mailto:horms@verge.=
net.au">horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org</a>&gt; wrote:<br><blockquote class=3D"gmail_quo=
te" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"=
>On Wed, May 21, 2014 at 01:31:55PM -0700, Jesse Gross wrote:<br>

&gt; On Wed, May 21, 2014 at 8:31 AM, Simon Horman &lt;<a href=3D"javascrip=
t:;" onclick=3D"_e(event, &#39;cvml&#39;, &#39;horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org&#39;)">ho=
rms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org</a>&gt; wrote:<br>
&gt; &gt; On Tue, May 20, 2014 at 07:30:38PM -0700, Jesse Gross wrote:<br>
&gt; &gt;&gt; On Thu, May 15, 2014 at 4:07 PM, Simon Horman &lt;<a href=3D"=
javascript:;" onclick=3D"_e(event, &#39;cvml&#39;, &#39;horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org&=
#39;)">horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org</a>&gt; wrote:<br>
&gt; &gt;&gt; &gt; diff --git a/datapath/linux/compat/include/linux/netdevi=
ce.h b/datapath/linux/compat/include/linux/netdevice.h<br>
&gt; &gt;&gt; &gt; index d726390..0381002 100644<br>
&gt; &gt;&gt; &gt; --- a/datapath/linux/compat/include/linux/netdevice.h<br=
>
&gt; &gt;&gt; &gt; +++ b/datapath/linux/compat/include/linux/netdevice.h<br=
>
&gt; &gt;&gt; &gt; +#if LINUX_VERSION_CODE &lt; KERNEL_VERSION(2,6,38)<br>
&gt; &gt;&gt; &gt; =C2=A0#define netif_skb_features rpl_netif_skb_features<=
br>
&gt; &gt;&gt; &gt; =C2=A0netdev_features_t rpl_netif_skb_features(struct sk=
_buff *skb);<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; Currently this function doesn&#39;t look at mpls_features. Sh=
ould it for<br>
&gt; &gt;&gt; things other than TSO?<br>
&gt; &gt;<br>
&gt; &gt; It seems to me that rpl_netif_skb_features is only used by<br>
&gt; &gt; rpl_dev_queue_xmit().<br>
&gt; &gt;<br>
&gt; &gt; If that is the case then I don&#39;t think it is necessary to exa=
mine<br>
&gt; &gt; mpls_features, which was introduced in v3.11, as rpl_dev_queue_xm=
it()<br>
&gt; &gt; only exists for older kernel versions.<br>
&gt;<br>
&gt; Sorry, I actually meant for upstream. I agree that the compatibility<b=
r>
&gt; code reflects current kernels as written.<br>
&gt;<br>
&gt; It seems like the checks in dev_hard_start_xmit() won&#39;t take<br>
&gt; mpls_features (or the presence of MPLS) into account when deciding<br>
&gt; whether to emulate the offload or pass the skb directly to the NIC. In=
<br>
&gt; the GSO code itself, we look at mpls_features but if we never get<br>
&gt; there then it will be too late.<br>
<br>
I am reasonably sure that when I merged the MPLS GSO code into mainline<br>
that it worked for the case where a non-MPLS GSO packet became an MPLS GSO<=
br>
packet (due to a push MPLS action). But that was a while ago and looking<br=
>
over the code its not obvious to my why that case would work.<br>
<br>
I&#39;ll do some testing an analysis and propose a fix if necessary.<br>
<br>
Would that address your concern?<br>
</blockquote><div><br></div><div>Yes, that&#39;s fine.<span></span>=C2=A0</=
div>

--001a11c2c6f68121c404f9f1b42b--

--===============2038334637057180332==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============2038334637057180332==--
