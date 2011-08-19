From: San Mehat <san@google.com>
Subject: Re: [RFC 0/0] Introducing a generic socket offload framework
Date: Fri, 19 Aug 2011 07:44:10 -0700
Message-ID: <CAPi7mHrbVQMBBzS_GDJVrFrgUCcK8_hw-GNbcOBYs1iyBV-f3g@mail.gmail.com>
References: <20110818220756.5C93E5C80B@san.sea.corp.google.com>
	<1313758185.16299.43.camel@mojatatu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6789239375104267897=="
Cc: mst@redhat.com, netdev@vger.kernel.org, miche@google.com,
        linux-kernel@vger.kernel.org,
        virtualization@lists.linux-foundation.org, digitaleric@google.com,
        mikew@google.com, maccarro@google.com, davem@davemloft.net
To: jhs@mojatatu.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1313758185.16299.43.camel@mojatatu>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Mime-version: 1.0
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--===============6789239375104267897==
Content-Type: multipart/alternative; boundary=20cf3005154630940104aadcc33d

--20cf3005154630940104aadcc33d
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Aug 19, 2011 at 5:49 AM, jamal <hadi@cyberus.ca> wrote:

> On Thu, 2011-08-18 at 15:07 -0700, San Mehat wrote:
> > TL;DR
> > -----
> > In this RFC we propose the introduction of the concept of hardware socket
> > offload to the Linux kernel. Patches will accompany this RFC in a few
> days,
> > but we felt we had enough on the design to solicit constructive
> discussion
> > from the community at-large.
> >
>
> [..]
>
> > ALTERNATIVE STRATEGIES
> > ----------------------
> >
> > An alternative strategy for providing similar functionality involves
> either
> > modifying glibc or using LD_PRELOAD tricks to intercept socket calls. We
> were
> > forced to rule this out due to the complexity (and fragility) involved
> with
> > attempting to maintain a general solution compatible across various
> > distributions where platform-libraries differ.
>
> Above should have been in your TL;DR;->
>
> LD_PRELOAD is also horrible because of the granularity of the socket
> calls;
> Having things in the kernel and specifically tagging socket as needing
> this feature is much much more manageable.
>
> Tying things to virtualization may miss the big picture because there
> are many other use cases for intercepting socket calls, example:
> Samir Bellabes <sam@synack.fr> has been trying to get what he refers to
> as "personal firewall" (equivalent to the silly windows firewall) which
> prompts the user "ping from blah, do you want to allow a response?"
> That requires intercepting send/recv calls, prompt the user in possibly
> some pop-up and act based on response. It requires looking at content.
> He is trying to use selinux for that interface,
> but i think this would be the right abstraction.
>

I agree; there's no reason this needs to be tied to virtualization - it was
just the
driving force behind the design. I will generalize the backend interface
types


> I hope you plan to support send/recv.
>

yes


> I also hope you add support for SOCK_RAW (and maybe SOCK_PACKET).
>
>
 Can you explain a good use-case for SOCK_RAW in this type of environment?
We were noodling it around locally and couldn't come up with one that we
needed to support.

Q: If you want this to be transparent to the apps, who/what is doing
> the tagging of SOCK_HWASSIST? clearly not the app if you dont want to
> change it.
>
>
 The decision of whether to tag a socket or not is made by the 'hardware'

I like the uri abstraction if it doesnt come at the expense of the
> app transparency.
>
>
Thank you,

-san


> cheers,
> jamal
>
>


-- 
San Mehat | Staff Software Engineer | san@google.com | 415-366-6172

--20cf3005154630940104aadcc33d
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, Aug 19, 2011 at 5:49 AM, jamal <=
span dir=3D"ltr">&lt;<a href=3D"mailto:hadi@cyberus.ca">hadi@cyberus.ca</a>=
&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0=
 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">On Thu, 2011-08-18 at 15:07 -0700, San Mehat wrote:<br>
&gt; TL;DR<br>
&gt; -----<br>
&gt; In this RFC we propose the introduction of the concept of hardware soc=
ket<br>
&gt; offload to the Linux kernel. Patches will accompany this RFC in a few =
days,<br>
&gt; but we felt we had enough on the design to solicit constructive discus=
sion<br>
&gt; from the community at-large.<br>
&gt;<br>
<br>
</div>[..]<br>
<div class=3D"im"><br>
&gt; ALTERNATIVE STRATEGIES<br>
&gt; ----------------------<br>
&gt;<br>
&gt; An alternative strategy for providing similar functionality involves e=
ither<br>
&gt; modifying glibc or using LD_PRELOAD tricks to intercept socket calls. =
We were<br>
&gt; forced to rule this out due to the complexity (and fragility) involved=
 with<br>
</div>&gt; attempting to maintain a general solution compatible across vari=
ous<br>
<div class=3D"im">&gt; distributions where platform-libraries differ.<br>
<br>
</div>Above should have been in your TL;DR;-&gt;<br>
<br>
LD_PRELOAD is also horrible because of the granularity of the socket<br>
calls;<br>
Having things in the kernel and specifically tagging socket as needing<br>
this feature is much much more manageable.<br>
<br>
Tying things to virtualization may miss the big picture because there<br>
are many other use cases for intercepting socket calls, example:<br>
Samir Bellabes &lt;<a href=3D"mailto:sam@synack.fr">sam@synack.fr</a>&gt; h=
as been trying to get what he refers to<br>
as &quot;personal firewall&quot; (equivalent to the silly windows firewall)=
 which<br>
prompts the user &quot;ping from blah, do you want to allow a response?&quo=
t;<br>
That requires intercepting send/recv calls, prompt the user in possibly<br>
some pop-up and act based on response. It requires looking at content.<br>
He is trying to use selinux for that interface,<br>
but i think this would be the right abstraction.<br></blockquote><div><br><=
/div><span class=3D"Apple-style-span" style=3D"color: rgb(51, 51, 51); font=
-family: arial, sans-serif; font-size: 13px; background-color: rgba(255, 25=
5, 255, 0.917969); "><div>
I agree; there&#39;s no reason this needs to be tied to virtualization - it=
 was just the</div></span><div><span class=3D"Apple-style-span" style=3D"co=
lor: rgb(51, 51, 51); font-family: arial, sans-serif; font-size: 13px; back=
ground-color: rgba(255, 255, 255, 0.917969); ">driving force behind the des=
ign. I will generalize the backend interface types</span></div>
<div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex;">
I hope you plan to support send/recv.<br></blockquote><div><br></div><div>y=
es</div><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0=
 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
I also hope you add support for SOCK_RAW (and maybe SOCK_PACKET).<br>
<br></blockquote><div><br></div><div>=A0<span class=3D"Apple-style-span" st=
yle=3D"color: rgb(51, 51, 51); font-family: arial, sans-serif; font-size: 1=
3px; background-color: rgba(255, 255, 255, 0.917969); ">Can you explain a g=
ood use-case for SOCK_RAW in this type of environment? We were noodling it =
around locally and couldn&#39;t come up with one that we needed to support.=
</span></div>
<div><span class=3D"Apple-style-span" style=3D"color: rgb(51, 51, 51); font=
-family: arial, sans-serif; font-size: 13px; background-color: rgba(255, 25=
5, 255, 0.917969); "><br></span></div><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">

Q: If you want this to be transparent to the apps, who/what is doing<br>
the tagging of SOCK_HWASSIST? clearly not the app if you dont want to<br>
change it.<br>
<br></blockquote><div><br></div><div>=A0The decision of whether to tag a so=
cket or not is made by the &#39;hardware&#39;</div><div><br></div><blockquo=
te class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc so=
lid;padding-left:1ex;">

I like the uri abstraction if it doesnt come at the expense of the<br>
app transparency.<br>
<br></blockquote><div><br></div><div>Thank you,</div><div><br></div><div>-s=
an</div><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0=
 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
cheers,<br>
<span class=3D"HOEnZb"><font color=3D"#888888">jamal<br>
<br>
</font></span></blockquote></div><br><br clear=3D"all"><div><br></div>-- <b=
r><span style=3D"font-family:&#39;Times New Roman&#39;;font-size:medium"><d=
iv style=3D"line-height:1.5em;padding-top:10px;margin-top:10px;color:rgb(85=
, 85, 85);font-family:sans-serif;font-size:small">
<span style=3D"border-top-width:2px;border-right-width:0px;border-bottom-wi=
dth:0px;border-left-width:0px;border-top-style:solid;border-right-style:sol=
id;border-bottom-style:solid;border-left-style:solid;border-top-color:rgb(2=
13, 15, 37);border-right-color:rgb(213, 15, 37);border-bottom-color:rgb(213=
, 15, 37);border-left-color:rgb(213, 15, 37);padding-top:2px;margin-top:2px=
">San Mehat=A0|</span><span style=3D"border-top-width:2px;border-right-widt=
h:0px;border-bottom-width:0px;border-left-width:0px;border-top-style:solid;=
border-right-style:solid;border-bottom-style:solid;border-left-style:solid;=
border-top-color:rgb(51, 105, 232);border-right-color:rgb(51, 105, 232);bor=
der-bottom-color:rgb(51, 105, 232);border-left-color:rgb(51, 105, 232);padd=
ing-top:2px;margin-top:2px">=A0Staff Software Engineer=A0|</span><span styl=
e=3D"border-top-width:2px;border-right-width:0px;border-bottom-width:0px;bo=
rder-left-width:0px;border-top-style:solid;border-right-style:solid;border-=
bottom-style:solid;border-left-style:solid;border-top-color:rgb(0, 153, 57)=
;border-right-color:rgb(0, 153, 57);border-bottom-color:rgb(0, 153, 57);bor=
der-left-color:rgb(0, 153, 57);padding-top:2px;margin-top:2px">=A0<a href=
=3D"mailto:san@google.com" target=3D"_blank">san@google.com</a>=A0|</span><=
span style=3D"border-top-width:2px;border-right-width:0px;border-bottom-wid=
th:0px;border-left-width:0px;border-top-style:solid;border-right-style:soli=
d;border-bottom-style:solid;border-left-style:solid;border-top-color:rgb(23=
8, 178, 17);border-right-color:rgb(238, 178, 17);border-bottom-color:rgb(23=
8, 178, 17);border-left-color:rgb(238, 178, 17);padding-top:2px;margin-top:=
2px">=A0415-366-6172</span></div>
</span><br>

--20cf3005154630940104aadcc33d--

--===============6789239375104267897==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linux-foundation.org/mailman/listinfo/virtualization
--===============6789239375104267897==--
