From: Baolin Wang <baolin.wang@linaro.org>
Subject: Re: [PATCH 01/11] linux/time64.h:Introduce the 'struct itimerspec64'
 for 64bit
Date: Tue, 21 Apr 2015 16:19:15 +0800
Message-ID: <CAMz4kuJ958NnuDV9NLZk2yGqH0wC8UaRsUTPsFutcxq-4ZpmHw@mail.gmail.com>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org>
 <1429509459-17068-2-git-send-email-baolin.wang@linaro.org>
 <alpine.DEB.2.11.1504202112130.13914@nanos>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8359599318427021445=="
Cc: Xunlei Pang <pang.xunlei@linaro.org>, peterz@infradead.org,
 heiko.carstens@de.ibm.com, paulus@samba.org, cl@linux.com,
 Heena Sirwani <heenasirwani@gmail.com>, linux-arch@vger.kernel.org,
 linux-s390@vger.kernel.org, y2038 Mailman List <y2038@lists.linaro.org>,
 rafael.j.wysocki@intel.com, Andrew Hunter <ahh@google.com>,
 =?UTF-8?B?RnLDqWTDqXJpYyBXZWlzYmVja2Vy?= <fweisbec@gmail.com>,
 Paul Turner <pjt@google.com>, riel@redhat.com, Arnd Bergmann <arnd@arndb.de>,
 Richard Cochran <richardcochran@gmail.com>, schwidefsky@de.ibm.com,
 John Stultz <john.stultz@linaro.org>, rth@twiddle.net,
 gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, tj@kernel.org, linux390@de.ibm.com,
 linuxppc-dev@lists.ozlabs.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <alpine.DEB.2.11.1504202112130.13914@nanos>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

--===============8359599318427021445==
Content-Type: multipart/alternative; boundary=f46d04343dd0c8ed17051437b366

--f46d04343dd0c8ed17051437b366
Content-Type: text/plain; charset=UTF-8

On 21 April 2015 at 03:14, Thomas Gleixner <tglx@linutronix.de> wrote:

> On Mon, 20 Apr 2015, Baolin Wang wrote:
> > This patch introduces the 'struct itimerspec64' for 64bit to replace
> itimerspec,
> > and also introduces the conversion methods: itimerspec64_to_itimerspec()
> and
> > itimerspec_to_itimerspec64(), that makes itimerspec to ready for 2038
> year.
> >
> > Signed-off-by: Baolin Wang <baolin.wang@linaro.org>
> > ---
> >  include/linux/time64.h |   13 +++++++++++++
> >  1 file changed, 13 insertions(+)
> >
> > diff --git a/include/linux/time64.h b/include/linux/time64.h
> > index a383147..3647bdd 100644
> > --- a/include/linux/time64.h
> > +++ b/include/linux/time64.h
> > @@ -18,6 +18,11 @@ struct timespec64 {
> >  };
> >  #endif
> >
> > +struct itimerspec64 {
> > +     struct timespec64 it_interval;  /* timer period */
> > +     struct timespec64 it_value;     /* timer expiration */
> > +};
> > +
> >  /* Parameters used to convert the timespec values: */
> >  #define MSEC_PER_SEC 1000L
> >  #define USEC_PER_MSEC        1000L
> > @@ -187,4 +192,12 @@ static __always_inline void
> timespec64_add_ns(struct timespec64 *a, u64 ns)
> >
> >  #endif
> >
> > +#define itimerspec64_to_itimerspec(its64) \
>
> > +#define itimerspec_to_itimerspec64(its) \
>
> 1.) Make these static inlines please. These macros are not typesafe.
>
> 2.) Use pointers to the input value.
>
> Thanks.
>
>         tglx
>


Thanks for your comments, i'll fix in next patch.
-- 
Baolin.wang
Best Regards

--f46d04343dd0c8ed17051437b366
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On 21 April 2015 at 03:14, Thomas Gleixner <span dir=3D"ltr">&lt;<a hre=
f=3D"mailto:tglx@linutronix.de" target=3D"_blank">tglx@linutronix.de</a>&gt=
;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 =
.8ex;border-left:1px #ccc solid;padding-left:1ex"><div class=3D"HOEnZb"><di=
v class=3D"h5">On Mon, 20 Apr 2015, Baolin Wang wrote:<br>
&gt; This patch introduces the &#39;struct itimerspec64&#39; for 64bit to r=
eplace itimerspec,<br>
&gt; and also introduces the conversion methods: itimerspec64_to_itimerspec=
() and<br>
&gt; itimerspec_to_itimerspec64(), that makes itimerspec to ready for 2038 =
year.<br>
&gt;<br>
&gt; Signed-off-by: Baolin Wang &lt;<a href=3D"mailto:baolin.wang@linaro.or=
g">baolin.wang@linaro.org</a>&gt;<br>
&gt; ---<br>
&gt;=C2=A0 include/linux/time64.h |=C2=A0 =C2=A013 +++++++++++++<br>
&gt;=C2=A0 1 file changed, 13 insertions(+)<br>
&gt;<br>
&gt; diff --git a/include/linux/time64.h b/include/linux/time64.h<br>
&gt; index a383147..3647bdd 100644<br>
&gt; --- a/include/linux/time64.h<br>
&gt; +++ b/include/linux/time64.h<br>
&gt; @@ -18,6 +18,11 @@ struct timespec64 {<br>
&gt;=C2=A0 };<br>
&gt;=C2=A0 #endif<br>
&gt;<br>
&gt; +struct itimerspec64 {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0struct timespec64 it_interval;=C2=A0 /* timer per=
iod */<br>
&gt; +=C2=A0 =C2=A0 =C2=A0struct timespec64 it_value;=C2=A0 =C2=A0 =C2=A0/*=
 timer expiration */<br>
&gt; +};<br>
&gt; +<br>
&gt;=C2=A0 /* Parameters used to convert the timespec values: */<br>
&gt;=C2=A0 #define MSEC_PER_SEC 1000L<br>
&gt;=C2=A0 #define USEC_PER_MSEC=C2=A0 =C2=A0 =C2=A0 =C2=A0 1000L<br>
&gt; @@ -187,4 +192,12 @@ static __always_inline void timespec64_add_ns(str=
uct timespec64 *a, u64 ns)<br>
&gt;<br>
&gt;=C2=A0 #endif<br>
&gt;<br>
&gt; +#define itimerspec64_to_itimerspec(its64) \<br>
<br>
</div></div>&gt; +#define itimerspec_to_itimerspec64(its) \<br>
<br>
1.) Make these static inlines please. These macros are not typesafe.<br>
<br>
2.) Use pointers to the input value.<br>
<br>
Thanks.<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 tglx<br>
</blockquote></div><br><br clear=3D"all"><div>Thanks for your comments, i&#=
39;ll fix in next patch.</div>-- <br><div class=3D"gmail_signature"><div di=
r=3D"ltr"><div>Baolin.wang<br></div>Best Regards<br></div></div>
</div></div>

--f46d04343dd0c8ed17051437b366--

--===============8359599318427021445==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTGludXhwcGMt
ZGV2IG1haWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJzLm9yZwpodHRwczovL2xp
c3RzLm96bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2

--===============8359599318427021445==--
