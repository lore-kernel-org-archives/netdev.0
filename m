From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!  2.6.28
Date: Wed, 14 Jan 2009 03:53:49 +0200
Message-ID: <200901140353.49730.denys@visp.net.lb>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt> <496AF0CE.7060406@trash.net> <2105.192.168.1.3.1231753688.squirrel@webmail.decimal.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Patrick McHardy" <kaber@trash.net>,
	"Jarek Poplawski" <jarkao2@gmail.com>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: "Jorge Bastos" <mysql.jorge@decimal.pt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:40472 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754049AbZANBx4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 20:53:56 -0500
In-Reply-To: <2105.192.168.1.3.1231753688.squirrel@webmail.decimal.pt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jorge - i guess your traffic is locally generated (on same PC where is =
shaper,=20
this traffic generated), thats why shaping was not precise, with enable=
d=20
GSO/TSO. I am right?

My conclusion based on:
eth0 =A0 =A0 =A0Link encap:Ethernet =A0HWaddr 00:13:d4:68:c6:33
=A0 =A0 =A0 =A0 =A0 inet addr:195.23.114.76 =A0Bcast:195.23.114.79 =A0M=
ask:255.255.255.248

and
/sbin/tc filter add dev eth0 parent 1:0 protocol ip prio 100 u32 match =
ip
src 195.23.114.76 match ip sport 80 0xffff classid 1
:1280



My traffic is "transit", means just passing router. I guess if it is co=
rrect,=20
there must be statement about difference in locally generated traffic a=
nd=20
transit traffic. TSO/GSO offloading i guess not done for "passing thru"=
=20
traffic.

On Monday 12 January 2009 11:48:08 Jorge Bastos wrote:
> Hi Patrick,
>
> >> I guess not: it's about better resolution, so e.g. when 2% matters=
=2E
> >> And it matters for a desktop box, if you care about responsiveness=
=2E
> >
> > Just wondering since this thread is very hard to follow with all
> > the top postings, incorrect timestamps on mails etc. - has there
> > been a resolution to this problem?
>
> Top posting are my fault, sorry!
> Yes for me got solved with disable GSO, TSO and SG.
> With them disabled, CBQ+TCF works as expected.
> My 100Mbit NIC always worked because this values were off by default,
> that's Why i start posting that it worked with a 100Mbit NIC and not =
with
> a 1000Mbit NIC, the reason were the values were off dby default.
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


