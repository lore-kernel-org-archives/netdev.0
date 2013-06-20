From: xiaoming gao <gxm.linux.kernel@gmail.com>
Subject: Fwd: [PATCH] net bridge: add null pointer check, fix panic
Date: Thu, 20 Jun 2013 14:53:44 +0800
Message-ID: <CAHBR9PJRWM-DKi014QaC2zUNMUWDFv6+5R8LpYkYqJA+ZVKmbQ@mail.gmail.com>
References: <51C2710D.2060405@gmail.com> <51C2721B.9050603@gmail.com>
	<1371704129.3252.356.camel@edumazet-glaptop>
	<CAHBR9PJQRw2vuSaG6gpUAGVYsrotNVTjYU_YY6jsA6o0mq4-Jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=001a11c2165c41ac7304df9068cb
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAHBR9PJQRw2vuSaG6gpUAGVYsrotNVTjYU_YY6jsA6o0mq4-Jw@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--001a11c2165c41ac7304df9068cb
Content-Type: text/plain; charset=ISO-8859-1

HI Eric
the problem is as follow:
br_del_if()-->del_nbp():

list_del_rcu(&p->list);
dev->priv_flags &= ~IFF_BRIDGE_PORT;

------>at this point, the nic be deleting still have rx_handler , so , may
in br_handle_frame()
------>br_port_exists() will return false,so br_get_port_rcu() will return
NULL
------>so in br_handle_frame , there will be a null panic.

netdev_rx_handler_unregister(dev);
synchronize_net();


i have checked commit 00cfec37484761a44, i think it didn't fix this bug..

thanks.




On Thu, Jun 20, 2013 at 12:55 PM, Eric Dumazet <eric.dumazet@gmail.com>wrote:

> On Thu, 2013-06-20 at 11:08 +0800, xiaoming gao wrote:
> > From: newtongao <newtongao@tencent.com>
> > Date: Wed, 19 Jun 2013 14:58:33 +0800
> > Subject: [PATCH] net bridge: add null pointer check,fix panic
> >
> > in kernel 3.0, br_port_get_rcu() may return NULL when network interface
> be deleting from bridge,
> > but in function br_handle_frame and br_handle_local_finish, the pointer
> didn't be checked before using,
> > so all br_port_get_rcu callers must do null check,or there occurs the
> null pointer panic.
> >
> > kernel 3.4 also has this bug,i have verified.
> > mainline kernel still did not  check br_port_get_rcu()'s NULL pointer,
> but i have not tested it yet.
>
> Please check current version before sending a patch.
>
> This was most probably fixed in commit 00cfec37484761a44
> ("net: add a synchronize_net() in netdev_rx_handler_unregister()")
>
> Thanks
>
>
>

--001a11c2165c41ac7304df9068cb
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_default" style=3D"font-family:arial,he=
lvetica,sans-serif;font-size:small"><span style=3D"font-family:arial,sans-s=
erif">HI Eric</span><br></div><div class=3D"gmail_quote"><div dir=3D"ltr"><=
div><div class=3D"gmail_default" style=3D"font-family:arial,helvetica,sans-=
serif;font-size:small">

the problem is as follow:</div><div class=3D"gmail_default" style=3D"font-f=
amily:arial,helvetica,sans-serif;font-size:small">br_del_if()--&gt;del_nbp(=
):</div><div class=3D"gmail_default" style=3D"font-family:arial,helvetica,s=
ans-serif;font-size:small">

<br></div><div class=3D"gmail_default"><font face=3D"arial, helvetica, sans=
-serif">list_del_rcu(&amp;p-&gt;list);</font></div><div class=3D"gmail_defa=
ult"><font face=3D"arial, helvetica, sans-serif">dev-&gt;priv_flags &amp;=
=3D ~IFF_BRIDGE_PORT;</font></div>

<div class=3D"gmail_default"><font face=3D"arial, helvetica, sans-serif"><b=
r></font></div><div class=3D"gmail_default"><font face=3D"arial, helvetica,=
 sans-serif" color=3D"#0000ff">------&gt;at this point, the nic be deleting=
 still have rx_handler , so , may in br_handle_frame()</font></div>

<div class=3D"gmail_default"><font face=3D"arial, helvetica, sans-serif" co=
lor=3D"#0000ff">------&gt;br_port_exists() will return false,so br_get_port=
_rcu() will return NULL</font></div><div class=3D"gmail_default"><font face=
=3D"arial, helvetica, sans-serif" color=3D"#0000ff">------&gt;so in br_hand=
le_frame , there will be a null panic.</font></div>

<div class=3D"gmail_default"><font face=3D"arial, helvetica, sans-serif"><b=
r></font></div><div class=3D"gmail_default"><font face=3D"arial, helvetica,=
 sans-serif">netdev_rx_handler_unregister(dev);</font></div><div class=3D"g=
mail_default">

<font face=3D"arial, helvetica, sans-serif">synchronize_net();</font></div>=
<br></div><div><br></div><div><div class=3D"gmail_default" style=3D"font-fa=
mily:arial,helvetica,sans-serif;font-size:small">i have checked commit=A0<s=
pan style=3D"font-family:arial,sans-serif;font-size:13px">00cfec37484761a44=
, i think it didn&#39;t fix this bug..</span></div>

<div class=3D"gmail_default" style=3D"font-family:arial,helvetica,sans-seri=
f;font-size:small"><br></div><div class=3D"gmail_default" style=3D"font-fam=
ily:arial,helvetica,sans-serif;font-size:small">thanks.</div><br></div><div=
><br>

</div></div><div class=3D"HOEnZb"><div class=3D"h5"><div class=3D"gmail_ext=
ra"><br><br><div class=3D"gmail_quote">On Thu, Jun 20, 2013 at 12:55 PM, Er=
ic Dumazet <span dir=3D"ltr">&lt;<a href=3D"mailto:eric.dumazet@gmail.com" =
target=3D"_blank">eric.dumazet@gmail.com</a>&gt;</span> wrote:<br>

<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div>On Thu, 2013-06-20 at 11:08 +0800, xiao=
ming gao wrote:<br>
&gt; From: newtongao &lt;<a href=3D"mailto:newtongao@tencent.com" target=3D=
"_blank">newtongao@tencent.com</a>&gt;<br>
&gt; Date: Wed, 19 Jun 2013 14:58:33 +0800<br>
&gt; Subject: [PATCH] net bridge: add null pointer check,fix panic<br>
&gt;<br>
&gt; in kernel 3.0, br_port_get_rcu() may return NULL when network interfac=
e be deleting from bridge,<br>
&gt; but in function br_handle_frame and br_handle_local_finish, the pointe=
r didn&#39;t be checked before using,<br>
&gt; so all br_port_get_rcu callers must do null check,or there occurs the =
null pointer panic.<br>
&gt;<br>
&gt; kernel 3.4 also has this bug,i have verified.<br>
&gt; mainline kernel still did not =A0check br_port_get_rcu()&#39;s NULL po=
inter, but i have not tested it yet.<br>
<br>
</div>Please check current version before sending a patch.<br>
<br>
This was most probably fixed in commit 00cfec37484761a44<br>
(&quot;net: add a synchronize_net() in netdev_rx_handler_unregister()&quot;=
)<br>
<br>
Thanks<br>
<br>
<br>
</blockquote></div><br></div>
</div></div></div><br></div>

--001a11c2165c41ac7304df9068cb--
