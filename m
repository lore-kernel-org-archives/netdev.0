From: Baolin Wang <baolin.wang@linaro.org>
Subject: Re: [Y2038] [PATCH 05/11] time/posix-timers:Convert to the 64bit
 methods for k_clock callback functions
Date: Tue, 21 Apr 2015 16:55:19 +0800
Message-ID: <CAMz4ku+EHpp4G6xu_P9f4G+zZgh9_bn7cTCgH-rEqNXiYTpU7w@mail.gmail.com>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org>
 <alpine.DEB.2.11.1504202243070.13914@nanos>
 <CAMz4kuKF2sU4tMD7UtDobu2kVDMp7cfHNERSPQ9Yyzs80tOzYg@mail.gmail.com>
 <8072977.i0FsrGW3CD@wuerfel>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6500401886810811241=="
Cc: Xunlei Pang <pang.xunlei@linaro.org>, peterz@infradead.org,
 heiko.carstens@de.ibm.com, paulus@samba.org, cl@linux.com,
 Heena Sirwani <heenasirwani@gmail.com>, linux-arch@vger.kernel.org,
 linux-s390@vger.kernel.org, y2038 Mailman List <y2038@lists.linaro.org>,
 rafael.j.wysocki@intel.com, Andrew Hunter <ahh@google.com>,
 =?UTF-8?B?RnLDqWTDqXJpYyBXZWlzYmVja2Vy?= <fweisbec@gmail.com>,
 Paul Turner <pjt@google.com>, riel@redhat.com,
 Richard Cochran <richardcochran@gmail.com>, tj@kernel.org,
 John Stultz <john.stultz@linaro.org>, Thomas Gleixner <tglx@linutronix.de>,
 rth@twiddle.net, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, schwidefsky@de.ibm.com, linux390@de.ibm.com,
 linuxppc-dev@lists.ozlabs.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <8072977.i0FsrGW3CD@wuerfel>
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

--===============6500401886810811241==
Content-Type: multipart/alternative; boundary=f46d043c7f46c8f2d40514383460

--f46d043c7f46c8f2d40514383460
Content-Type: text/plain; charset=UTF-8

On 21 April 2015 at 16:45, Arnd Bergmann <arnd@arndb.de> wrote:

> On Tuesday 21 April 2015 16:36:13 Baolin Wang wrote:
> > On 21 April 2015 at 04:48, Thomas Gleixner <tglx@linutronix.de> wrote:
> >
> > > On Mon, 20 Apr 2015, Baolin Wang wrote:
> > > >  /* Set clock_realtime */
> > > >  static int posix_clock_realtime_set(const clockid_t which_clock,
> > > > -                                 const struct timespec *tp)
> > > > +                                 const struct timespec64 *tp)
> > > >  {
> > > > -     return do_sys_settimeofday(tp, NULL);
> > > > +     struct timespec ts = timespec64_to_timespec(*tp);
> > > > +
> > > > +     return do_sys_settimeofday(&ts, NULL);
> > >
> > > Sigh. No. We first provide a proper function for this, which takes a
> > > timespec64, i.e. do_sys_settimeofday64() instead of having this
> > > wrapper mess all over the place.
> > >
> >
> > Thanks for your comments,but if use do_sys_settimeofday64() here that
> > will  introduce
> > a security bug: do_sys_settimeofday contains a capability
> > check that normally prevents non-root users from setting the time.
> >
> > With your change, any user can set the system time.
>
> He was asking for a new do_sys_settimeofday64 function to be added,
> not using the low-level do_settimeofday64.
>
>         Arnd
>

Sorry for the misunderstand, i'll fix that in next patch. Thanks.

-- 
Baolin.wang
Best Regards

--f46d043c7f46c8f2d40514383460
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On 21 April 2015 at 16:45, Arnd Bergmann <span dir=3D"ltr">&lt;<a href=
=3D"mailto:arnd@arndb.de" target=3D"_blank">arnd@arndb.de</a>&gt;</span> wr=
ote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border=
-left:1px #ccc solid;padding-left:1ex"><span class=3D"">On Tuesday 21 April=
 2015 16:36:13 Baolin Wang wrote:<br>
&gt; On 21 April 2015 at 04:48, Thomas Gleixner &lt;<a href=3D"mailto:tglx@=
linutronix.de">tglx@linutronix.de</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; On Mon, 20 Apr 2015, Baolin Wang wrote:<br>
&gt; &gt; &gt;=C2=A0 /* Set clock_realtime */<br>
&gt; &gt; &gt;=C2=A0 static int posix_clock_realtime_set(const clockid_t wh=
ich_clock,<br>
&gt; &gt; &gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct tim=
espec *tp)<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct tim=
espec64 *tp)<br>
&gt; &gt; &gt;=C2=A0 {<br>
&gt; &gt; &gt; -=C2=A0 =C2=A0 =C2=A0return do_sys_settimeofday(tp, NULL);<b=
r>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0struct timespec ts =3D timespec64_to_ti=
mespec(*tp);<br>
&gt; &gt; &gt; +<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0return do_sys_settimeofday(&amp;ts, NUL=
L);<br>
&gt; &gt;<br>
&gt; &gt; Sigh. No. We first provide a proper function for this, which take=
s a<br>
&gt; &gt; timespec64, i.e. do_sys_settimeofday64() instead of having this<b=
r>
&gt; &gt; wrapper mess all over the place.<br>
&gt; &gt;<br>
&gt;<br>
&gt; Thanks for your comments,but if use do_sys_settimeofday64() here that<=
br>
&gt; will=C2=A0 introduce<br>
&gt; a security bug: do_sys_settimeofday contains a capability<br>
&gt; check that normally prevents non-root users from setting the time.<br>
&gt;<br>
&gt; With your change, any user can set the system time.<br>
<br>
</span>He was asking for a new do_sys_settimeofday64 function to be added,<=
br>
not using the low-level do_settimeofday64.<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 Arnd<br>
</font></span></blockquote></div><br>Sorry for the misunderstand, i&#39;ll =
fix that in next patch. Thanks.<br clear=3D"all"><div><br></div>-- <br><div=
 class=3D"gmail_signature"><div dir=3D"ltr"><div>Baolin.wang<br></div>Best =
Regards<br></div></div>
</div></div>

--f46d043c7f46c8f2d40514383460--

--===============6500401886810811241==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTGludXhwcGMt
ZGV2IG1haWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJzLm9yZwpodHRwczovL2xp
c3RzLm96bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2

--===============6500401886810811241==--
