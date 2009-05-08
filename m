From: John Rigby <jcrigby@gmail.com>
Subject: Re: [PATCH 02/12] fs_enet: Add MPC5121 FEC support.
Date: Thu, 7 May 2009 20:02:53 -0600
Message-ID: <4b73d43f0905071902y3b51d36ct2a04c560b5acdfb9@mail.gmail.com>
References: <1241640919-4650-1-git-send-email-wd@denx.de>
	<1241640919-4650-3-git-send-email-wd@denx.de>
	<fa686aa40905061333q29c263c8p24856c048e30f4d0@mail.gmail.com>
	<20090506220119.7322783420E8@gemini.denx.de>
	<fa686aa40905061529u11b231afle3b5bb10a2334ad0@mail.gmail.com>
	<20090506224134.83F1583420E8@gemini.denx.de>
	<fa686aa40905070709r7478837fnefb094d46f03ae0e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1728707583=="
Cc: netdev@vger.kernel.org, Piotr Ziecik <kosmo@semihalf.com>,
	Detlev Zundel <dzu@denx.de>
To: linuxppc <linuxppc-dev@ozlabs.org>, Wolfgang Denk <wd@denx.de>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <fa686aa40905070709r7478837fnefb094d46f03ae0e@mail.gmail.com>
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

--===============1728707583==
Content-Type: multipart/alternative; boundary=000e0cd32f98ce7eb804695d06d5

--000e0cd32f98ce7eb804695d06d5
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Wolfgang,

Welcome to my world and why I gave up on this months ago.

Everyone else,

One thing to consider here is a rewrite with the goal of a new improved fec
driver that would work on both 5121 and the various mx platforms that also
have this same fec core.

Also don't forget that the register map is the same on 512x, mx and coldfire
platforms but not on the other ppc platforms so if you want to one binary to
rule them all you will need to have an offest table or some such.

John

On Thu, May 7, 2009 at 8:09 AM, Grant Likely <grant.likely@secretlab.ca>wrote:

> On Wed, May 6, 2009 at 4:41 PM, Wolfgang Denk <wd@denx.de> wrote:
> > Dear Grant,
> >
> > In message <fa686aa40905061529u11b231afle3b5bb10a2334ad0@mail.gmail.com>
> you wrote:
> >>
> >> > Agreed that it's ugly, but duplicatio9ng the code would have been even
> >> > worse. I don't think that it has multiplatform - at least not as long
> >> > as you don't ask for one image that runs on 83xx and on 512x.
> >>
> >> Actually, I *am* asking for one image that runs on 83xx, 52xx and
> >> 521x.  I already can and do build and test a single image which boots
> >> on all my 52xx boards, on my 8349 board, and on my G4 Mac.
> >
> > He. I was afraid you'd say that ;-)
> >
> > In this case I need a helping hand as I can't figure out how to make
> > this work. Any suggestions?
>
> Hmmm, it is rather ugly because the layout of fec_t is so different.
> Easiest solution would be to duplicate the driver in its entirety, but
> as you say it results in a lot of duplicate code.  It might be the
> lesser of many weevils though.
>
> Second easiest would be to factor out all the common code in the
> driver into a separate .c file that gets included by a 'wrapper' .c
> file for each config which first includes the correct definition of
> fec_t.  This approach solves the duplicate code problem, but it also
> fell out of the ugly tree and hit every branch on the way down.
>
> ie: the wrappers would look something like this:
>
> fs_enet_cpm1.c:
> #include <asm/cpm1.h>
> #include "fs_enet_main.c"
>
> fs_enet_cpm2.c:
> #include <asm/cpm2.h>
> #include "fs_enet_main.c"
>
> fs_enet_512x.c:
> #include <asm/mpc512x.h>
> #include "fs_enet_main.c"
>
> And then the makefile would be something along the lines of:
> obj-${CONFIG_FS_ENET_CPM1_ += fs_enet_cpm1.o
> obj-${CONFIG_FS_ENET_CPM2_ += fs_enet_cpm2.o
> obj-${CONFIG_FS_ENET_MPC512x_ += fs_enet_512x.o
>
> A brief look at the driver suggests that access to the fec_t structure
> is restricted to the fec-mii.c and mac-fec.c files.  It might be
> appropriate to duplicate just those files and do some form of
> fs_enet_ops to select between them.
>
> While on the topic, it looks to me like the driver could really use
> some refactoring love.  Having multiple definitions of "fec_t" is
> confusing and potentially lead to hard to find bugs if the wrong
> header gets included by anyone.  I'd like to see all the fec specific
> stuff in arch/powerpc/include/asm moved into drivers/net/fs_enet and
> renamed to reflect the hardware it is associate with.  Stuff like
> "fec_t" is far to generic, not to mention that typedefs are
> discouraged now.
>
> Regardless, I feel your pain.  It is not a pretty situation.
>
> g.
>
> --
> Grant Likely, B.Sc., P.Eng.
> Secret Lab Technologies Ltd.
>

--000e0cd32f98ce7eb804695d06d5
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Wolfgang,<br><br>Welcome to my world and why I gave up on this months ago.<=
br><br>Everyone else,<br><br>One thing to consider here is a rewrite with t=
he goal of a new improved fec driver that would work on both 5121 and the v=
arious mx platforms that also have this same fec core.<br>
<br>Also don&#39;t forget that the register map is the same on 512x, mx and=
 coldfire platforms but not on the other ppc platforms so if you want to on=
e binary to rule them all you will need to have an offest table or some suc=
h.<br>
<br>John<br><br><div class=3D"gmail_quote">On Thu, May 7, 2009 at 8:09 AM, =
Grant Likely <span dir=3D"ltr">&lt;<a href=3D"mailto:grant.likely@secretlab=
.ca">grant.likely@secretlab.ca</a>&gt;</span> wrote:<br><blockquote class=
=3D"gmail_quote" style=3D"border-left: 1px solid rgb(204, 204, 204); margin=
: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
<div class=3D"im">On Wed, May 6, 2009 at 4:41 PM, Wolfgang Denk &lt;<a href=
=3D"mailto:wd@denx.de">wd@denx.de</a>&gt; wrote:<br>
&gt; Dear Grant,<br>
&gt;<br>
&gt; In message &lt;<a href=3D"mailto:fa686aa40905061529u11b231afle3b5bb10a=
2334ad0@mail.gmail.com">fa686aa40905061529u11b231afle3b5bb10a2334ad0@mail.g=
mail.com</a>&gt; you wrote:<br>
&gt;&gt;<br>
&gt;&gt; &gt; Agreed that it&#39;s ugly, but duplicatio9ng the code would h=
ave been even<br>
&gt;&gt; &gt; worse. I don&#39;t think that it has multiplatform - at least=
 not as long<br>
&gt;&gt; &gt; as you don&#39;t ask for one image that runs on 83xx and on 5=
12x.<br>
&gt;&gt;<br>
&gt;&gt; Actually, I *am* asking for one image that runs on 83xx, 52xx and<=
br>
&gt;&gt; 521x. =A0I already can and do build and test a single image which =
boots<br>
&gt;&gt; on all my 52xx boards, on my 8349 board, and on my G4 Mac.<br>
&gt;<br>
&gt; He. I was afraid you&#39;d say that ;-)<br>
&gt;<br>
&gt; In this case I need a helping hand as I can&#39;t figure out how to ma=
ke<br>
&gt; this work. Any suggestions?<br>
<br>
</div>Hmmm, it is rather ugly because the layout of fec_t is so different.<=
br>
Easiest solution would be to duplicate the driver in its entirety, but<br>
as you say it results in a lot of duplicate code. =A0It might be the<br>
lesser of many weevils though.<br>
<br>
Second easiest would be to factor out all the common code in the<br>
driver into a separate .c file that gets included by a &#39;wrapper&#39; .c=
<br>
file for each config which first includes the correct definition of<br>
fec_t. =A0This approach solves the duplicate code problem, but it also<br>
fell out of the ugly tree and hit every branch on the way down.<br>
<br>
ie: the wrappers would look something like this:<br>
<br>
fs_enet_cpm1.c:<br>
#include &lt;asm/cpm1.h&gt;<br>
#include &quot;fs_enet_main.c&quot;<br>
<br>
fs_enet_cpm2.c:<br>
#include &lt;asm/cpm2.h&gt;<br>
#include &quot;fs_enet_main.c&quot;<br>
<br>
fs_enet_512x.c:<br>
#include &lt;asm/mpc512x.h&gt;<br>
#include &quot;fs_enet_main.c&quot;<br>
<br>
And then the makefile would be something along the lines of:<br>
obj-${CONFIG_FS_ENET_CPM1_ +=3D fs_enet_cpm1.o<br>
obj-${CONFIG_FS_ENET_CPM2_ +=3D fs_enet_cpm2.o<br>
obj-${CONFIG_FS_ENET_MPC512x_ +=3D fs_enet_512x.o<br>
<br>
A brief look at the driver suggests that access to the fec_t structure<br>
is restricted to the fec-mii.c and mac-fec.c files. =A0It might be<br>
appropriate to duplicate just those files and do some form of<br>
fs_enet_ops to select between them.<br>
<br>
While on the topic, it looks to me like the driver could really use<br>
some refactoring love. =A0Having multiple definitions of &quot;fec_t&quot; =
is<br>
confusing and potentially lead to hard to find bugs if the wrong<br>
header gets included by anyone. =A0I&#39;d like to see all the fec specific=
<br>
stuff in arch/powerpc/include/asm moved into drivers/net/fs_enet and<br>
renamed to reflect the hardware it is associate with. =A0Stuff like<br>
&quot;fec_t&quot; is far to generic, not to mention that typedefs are<br>
discouraged now.<br>
<br>
Regardless, I feel your pain. =A0It is not a pretty situation.<br>
<div><div></div><div class=3D"h5"><br>
g.<br>
<br>
--<br>
Grant Likely, B.Sc., P.Eng.<br>
Secret Lab Technologies Ltd.<br>
</div></div></blockquote></div><br>

--000e0cd32f98ce7eb804695d06d5--

--===============1728707583==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
--===============1728707583==--
