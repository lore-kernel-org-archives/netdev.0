From: John Rigby <jcrigby@gmail.com>
Subject: Re: [PATCH 03/12] fs_enet: Add FEC TX Alignment workaround for
	MPC5121.
Date: Thu, 7 May 2009 20:36:39 -0600
Message-ID: <4b73d43f0905071936i9ba8551yc383820dd1ea1831@mail.gmail.com>
References: <1241640919-4650-1-git-send-email-wd@denx.de>
	<1241640919-4650-4-git-send-email-wd@denx.de>
	<fa686aa40905061337w6aa82f5aj787618ba108e528f@mail.gmail.com>
	<20090506221250.C977183420E8@gemini.denx.de>
	<fa686aa40905061542g2cf538bau5eebcfc154906810@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0540767555=="
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, Wolfgang Denk <wd@denx.de>,
	Detlev Zundel <dzu@denx.de>, Piotr Ziecik <kosmo@semihalf.com>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <fa686aa40905061542g2cf538bau5eebcfc154906810@mail.gmail.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

--===============0540767555==
Content-Type: multipart/alternative; boundary=000e0cd229d8839e6604695d7f56

--000e0cd229d8839e6604695d7f56
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

I was having deja-vu with this and realized that I have fixed at least some
of the objections to this patch.

Wolfgang you may want to look at the patch in my 5121 git tree here:

http://git.denx.de/?p=linux-mpc512x.git;a=commit;h=2950be3be42af7449941c3340998c27ef918f10f

It does runtime tx packet alignment  It also has fewer ifdefs and trys to
share more code.  It also has a header that explains everything including
that fact that there is not a runtime conflict sine the only other ppc that
has fec is 8xx which is not in the same family.

On Wed, May 6, 2009 at 4:42 PM, Grant Likely <grant.likely@secretlab.ca>wrote:

> On Wed, May 6, 2009 at 4:12 PM, Wolfgang Denk <wd@denx.de> wrote:
> > Dear Grant Likely,
> >
> > In message <fa686aa40905061337w6aa82f5aj787618ba108e528f@mail.gmail.com>
> you wrote:
> >>
> >> > The FEC on 5121 has problems with misaligned tx buffers.
> >> > The RM says any alignment is ok but empirical results
> >> > show that packet buffers ending in 0x1E will sometimes
> >> > hang the FEC. Other bad alignment does not hang but will
> >> > cause silent TX failures resulting in about a 1% packet
> >> > loss as tested by ping -f from a remote host.
> >> >
> >> > This patch is a work around that copies every tx packet
> >> > to an aligned skb before sending.
> >>
> >> OUCH!
> >
> > Yes :-(
> >
> >> > +#else
> >> > +#define tx_skb_align_workaround(dev, skb) (skb)
> >> > +#endif
> >>
> >> Another use of #ifdef blocks.  What is the multiplatform impact?
> >
> > Hm... Can you recommend a better way to solve the problem? Suggestions
> > are welcome.
>
> I'd rather see a runtime selectable workaround.  ie. enable it based
> on the compatible property.
>
> g.
>
> --
> Grant Likely, B.Sc., P.Eng.
> Secret Lab Technologies Ltd.
>

--000e0cd229d8839e6604695d7f56
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

I was having deja-vu with this and realized that I have fixed at least some=
 of the objections to this patch.=A0 <br><br>Wolfgang you may want to look =
at the patch in my 5121 git tree here:<br><br><a href=3D"http://git.denx.de=
/?p=3Dlinux-mpc512x.git;a=3Dcommit;h=3D2950be3be42af7449941c3340998c27ef918=
f10f">http://git.denx.de/?p=3Dlinux-mpc512x.git;a=3Dcommit;h=3D2950be3be42a=
f7449941c3340998c27ef918f10f</a><br>
<br>It does runtime tx packet alignment=A0 It also has fewer ifdefs and try=
s to share more code.=A0 It also has a header that explains everything incl=
uding that fact that there is not a runtime conflict sine the only other pp=
c that has fec is 8xx which is not in the same family.<br>
<br><div class=3D"gmail_quote">On Wed, May 6, 2009 at 4:42 PM, Grant Likely=
 <span dir=3D"ltr">&lt;<a href=3D"mailto:grant.likely@secretlab.ca">grant.l=
ikely@secretlab.ca</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quot=
e" style=3D"border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt =
0.8ex; padding-left: 1ex;">
<div class=3D"im">On Wed, May 6, 2009 at 4:12 PM, Wolfgang Denk &lt;<a href=
=3D"mailto:wd@denx.de">wd@denx.de</a>&gt; wrote:<br>
&gt; Dear Grant Likely,<br>
&gt;<br>
&gt; In message &lt;<a href=3D"mailto:fa686aa40905061337w6aa82f5aj787618ba1=
08e528f@mail.gmail.com">fa686aa40905061337w6aa82f5aj787618ba108e528f@mail.g=
mail.com</a>&gt; you wrote:<br>
&gt;&gt;<br>
&gt;&gt; &gt; The FEC on 5121 has problems with misaligned tx buffers.<br>
&gt;&gt; &gt; The RM says any alignment is ok but empirical results<br>
&gt;&gt; &gt; show that packet buffers ending in 0x1E will sometimes<br>
&gt;&gt; &gt; hang the FEC. Other bad alignment does not hang but will<br>
&gt;&gt; &gt; cause silent TX failures resulting in about a 1% packet<br>
&gt;&gt; &gt; loss as tested by ping -f from a remote host.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; This patch is a work around that copies every tx packet<br>
&gt;&gt; &gt; to an aligned skb before sending.<br>
&gt;&gt;<br>
&gt;&gt; OUCH!<br>
&gt;<br>
&gt; Yes :-(<br>
&gt;<br>
&gt;&gt; &gt; +#else<br>
&gt;&gt; &gt; +#define tx_skb_align_workaround(dev, skb) (skb)<br>
&gt;&gt; &gt; +#endif<br>
&gt;&gt;<br>
&gt;&gt; Another use of #ifdef blocks. =A0What is the multiplatform impact?=
<br>
&gt;<br>
&gt; Hm... Can you recommend a better way to solve the problem? Suggestions=
<br>
&gt; are welcome.<br>
<br>
</div>I&#39;d rather see a runtime selectable workaround. =A0ie. enable it =
based<br>
on the compatible property.<br>
<div><div></div><div class=3D"h5"><br>
g.<br>
<br>
--<br>
Grant Likely, B.Sc., P.Eng.<br>
Secret Lab Technologies Ltd.<br>
</div></div></blockquote></div><br>

--000e0cd229d8839e6604695d7f56--

--===============0540767555==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
--===============0540767555==--
