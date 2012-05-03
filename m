From: Amos Kong <kongjianjun@gmail.com>
Subject: IPv6 bonding in VM doesn't work (was Re: bonding and
	IPv6 "doesn't work"?)
Date: Thu, 3 May 2012 13:33:20 +0800
Message-ID: <CAFeW=pZAGgM-9xCcNTJ9PAtd5kDgZJY6UxpTvtK9iM-3t3VTVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=f46d0444ec67436c1b04bf1b24f5
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	qemu-devel@nongnu.org, Tomasz Chmielewski <mangoo@wpkg.org>,
	shemminger@linux-foundation.org, David Lamparter <equinox@diac24.net>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

--f46d0444ec67436c1b04bf1b24f5
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Jul 13, 2011 at 1:15 AM, Chris Friesen <chris.friesen@genband.com>wrote:

> On 07/12/2011 10:25 AM, Tomasz Chmielewski wrote:
>
>> On 12.07.2011 18:14, David Lamparter wrote:
>>
>
>  Your bonding peer is probably looping those
>>> packets back on the other link, most likely because...
>>>
>>>  Bonding Mode: load balancing (round-robin)
>>>>
>>>
>>> ... most likely because you maybe have a switch on the other side, and
>>> that switch expects you to do 802.3ad?
>>>
>>
>> It's a virtual machine, so the host shouldn't know or care much about
>> 802.3ad (I think!).
>>
>

Bonding mode 1 and 5 work when slave nics(guest) connect with same virtual
bridge in host.
other modes don't work.


>
> I suspect that connecting multiple links of a bond to the same unmanaged
> switch (or virtual bridge) is going to confuse things.
>
> Try using multiple virtual bridges instead, one for each slave in the
> bond.  That way they won't interfere with each other.
>


>>  Continue original thread: http://marc.info/?t=131048686200002&r=1&w=2

http://en.wikipedia.org/wiki/IEEE_802.1AX
""" With modes balance-rr, balance-xor, broadcast and 802.3ad all physical
ports in the link aggregation group _must reside on the same_ logical
switch, which in most scenarios will leave a single point of failure when
the physical switch to which both links are connected goes offline. Modes
active-backup, balance-tlb, and balance-alb can also be set up with two or
more switches."""

We could not resolve this issue by connect links to different virtual
bridges?
But it doesn't make sense to connect slave nics with same physical path,
NO stable /performance benefit.

What will happen if we connect two physical NIC directly (back-to-back)?
duplicated address detected?

BTW, openvswitch already support 802.3ad, it might resolve this issue.

Thanks, Amos

--f46d0444ec67436c1b04bf1b24f5
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div class=3D"gmail_extra"><div class=3D"gmail_quote">On Wed, Jul 13, 2011 =
at 1:15 AM, Chris Friesen <span dir=3D"ltr">&lt;<a href=3D"mailto:chris.fri=
esen@genband.com" target=3D"_blank">chris.friesen@genband.com</a>&gt;</span=
> wrote:<br>

<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div>On 07/12/2011 10:25 AM, Tomasz Chmielew=
ski wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
On 12.07.2011 18:14, David Lamparter wrote:<br>
</blockquote>
<br>
</div><div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bor=
der-left:1px #ccc solid;padding-left:1ex"><blockquote class=3D"gmail_quote"=
 style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">

Your bonding peer is probably looping those<br>
packets back on the other link, most likely because...<br>
<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
Bonding Mode: load balancing (round-robin)<br>
</blockquote>
<br>
... most likely because you maybe have a switch on the other side, and<br>
that switch expects you to do 802.3ad?<br>
</blockquote>
<br>
It&#39;s a virtual machine, so the host shouldn&#39;t know or care much abo=
ut<br>
802.3ad (I think!).<br></blockquote></div></blockquote><div><br><br>Bonding=
 mode 1 and 5 work when slave nics(guest) connect with same virtual bridge =
in host.<br>other modes don&#39;t work.<br>=A0</div><blockquote class=3D"gm=
ail_quote" style=3D"margin:0pt 0pt 0pt 0.8ex;border-left:1px solid rgb(204,=
204,204);padding-left:1ex">
<div><blockquote class=3D"gmail_quote" style=3D"margin:0pt 0pt 0pt 0.8ex;bo=
rder-left:1px solid rgb(204,204,204);padding-left:1ex">
</blockquote>
<br></div>
I suspect that connecting multiple links of a bond to the same unmanaged sw=
itch (or virtual bridge) is going to confuse things.<br>
<br>
Try using multiple virtual bridges instead, one for each slave in the bond.=
 =A0That way they won&#39;t interfere with each other.<span><font color=3D"=
#888888"><br></font></span></blockquote><div><br><br>&gt;&gt;=A0 Continue o=
riginal thread: <a href=3D"http://marc.info/?t=3D131048686200002&amp;r=3D1&=
amp;w=3D2" target=3D"_blank">http://marc.info/?t=3D131048686200002&amp;r=3D=
1&amp;w=3D2</a><br>

<br><a href=3D"http://en.wikipedia.org/wiki/IEEE_802.1AX" target=3D"_blank"=
>http://en.wikipedia.org/wiki/IEEE_802.1AX</a><br>&quot;&quot;&quot; With m=
odes balance-rr, balance-xor, broadcast and 802.3ad all physical=20
ports in the link aggregation group _<span style=3D"background-color:rgb(25=
5,0,0)">must reside on the same</span>_ logical=20
switch, which in most scenarios will leave a single point of failure=20
when the physical switch to which both links are connected goes offline.
 Modes active-backup, balance-tlb, and balance-alb can also be set up<span =
style=3D"background-color:rgb(255,153,102)">=20
with two or more</span> switches.&quot;&quot;&quot;<br><br>We could not res=
olve this issue by connect links to different virtual bridges?<br>But it do=
esn&#39;t make sense to connect slave nics with same physical path,=A0 <br>
NO stable /performance benefit.<br><br>What will happen if we connect two p=
hysical NIC directly (back-to-back)?<br>duplicated address detected?<br><br=
>BTW, openvswitch already support 802.3ad, it might resolve this issue.<br>
<br>Thanks, Amos<br></div></div></div>

--f46d0444ec67436c1b04bf1b24f5--
