From: Frediano Ziglio <freddy77@gmail.com>
Subject: Re: BUG in xennet_make_frags with paged skb data
Date: Mon, 10 Nov 2014 17:20:03 +0000
Message-ID: <CAHt6W4fFd17y0gXO9o=rrc86ErYNe_gcvvuc94j31ZrpR4huog@mail.gmail.com>
References: <20141106214940.GD44162@ubuntu-hedt> <545CA27F.4070400@citrix.com>
	<20141110143517.GA74005@ubuntu-hedt> <5460CEA5.3070201@citrix.com>
	<5460EA45.2080202@linaro.org> <5460EAF1.5020903@citrix.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5083918228855888436=="
Cc: Zoltan Kiss <zoltan.kiss@linaro.org>, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Bader <stefan.bader@canonical.com>, xen-devel@lists.xenproject.org,
	Jay Vosburgh <jay.vosburgh@canonical.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <5460EAF1.5020903@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

--===============5083918228855888436==
Content-Type: multipart/alternative; boundary=001a1136afd890138c0507845f7a

--001a1136afd890138c0507845f7a
Content-Type: text/plain; charset=UTF-8

2014-11-10 16:42 GMT+00:00 David Vrabel <david.vrabel@citrix.com>:

> On 10/11/14 16:39, Zoltan Kiss wrote:
> >
> > The BUG_ON suggested by Stefan would be still reasonable:
> >
> > BUG_ON(((page-compound_head(page))*PAGE_SIZE)+offset+len >
> > PAGE_SIZE<<compound_order(compound_head(page)));
>
> Well, it wouldn't trigger but I don't think it is useful any more.
>
> David
>
>
Looks like this structure was designed to just contains physical single
pages and was extended to support compound pages however there are still
some functions that assume the usage of single pages. Just for instance the
offset/size of fragments are computed from PAGE_SIZE. On x86 (4KB pages) if
your compound page is bigger than 64KB you cannot fully use for a fragment
as offset/size are 16 bits. Some functions in skbuff.c use kmap which is
limited to physical page.

Frediano

--001a1136afd890138c0507845f7a
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">2014=
-11-10 16:42 GMT+00:00 David Vrabel <span dir=3D"ltr">&lt;<a href=3D"mailto=
:david.vrabel@citrix.com" target=3D"_blank">david.vrabel@citrix.com</a>&gt;=
</span>:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bo=
rder-left:1px #ccc solid;padding-left:1ex"><span class=3D"">On 10/11/14 16:=
39, Zoltan Kiss wrote:<br>
&gt;<br>
&gt; The BUG_ON suggested by Stefan would be still reasonable:<br>
&gt;<br>
&gt; BUG_ON(((page-compound_head(page))*PAGE_SIZE)+offset+len &gt;<br>
&gt; PAGE_SIZE&lt;&lt;compound_order(compound_head(page)));<br>
<br>
</span>Well, it wouldn&#39;t trigger but I don&#39;t think it is useful any=
 more.<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
David<br>
<br></div></div></blockquote><div><br></div><div>Looks like this structure =
was designed to just contains physical single pages and was extended to sup=
port compound pages however there are still some functions that assume the =
usage of single pages. Just for instance the offset/size of fragments are c=
omputed from PAGE_SIZE. On x86 (4KB pages) if your compound page is bigger =
than 64KB you cannot fully use for a fragment as offset/size are 16 bits. S=
ome functions in skbuff.c use kmap which is limited to physical page.<br></=
div><div><br>Frediano<br><br></div></div></div></div>

--001a1136afd890138c0507845f7a--


--===============5083918228855888436==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Xen-devel mailing list
Xen-devel@lists.xen.org
http://lists.xen.org/xen-devel

--===============5083918228855888436==--
