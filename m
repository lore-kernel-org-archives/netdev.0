From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: Is there any function similar to inet_ntoa() in Kernel or
 NetFilter ?
Date: Mon, 24 Nov 2008 22:01:50 -0800
Message-ID: <1227592910.5511.38.camel@brick>
References: <192580.22596.qm@web111104.mail.gq1.yahoo.com>
	 <49252F1A.4060304@tihlde.org>
	 <43ca39800811211508i13b3073akfa48284f96eae69c@mail.gmail.com>
	 <AAF075CA-ECF9-440C-AF33-3845544A284D@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Julius Volz <julius.volz@gmail.com>, netdev@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:20097 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbYKYGBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 01:01:53 -0500
Received: by wf-out-1314.google.com with SMTP id 27so2620581wfd.4
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 22:01:52 -0800 (PST)
In-Reply-To: <AAF075CA-ECF9-440C-AF33-3845544A284D@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-11-24 at 21:03 -0500, Chuck Lever wrote:
> On Nov 21, 2008, at Nov 21, 2008, 6:08 PM, Julius Volz wrote:
> > On Thu, Nov 20, 2008 at 10:34 AM, Roar Bj=C3=B8rgum Rotvik <roarbr@=
tihlde.org=20
> > > wrote:
> >> Kunsheng Chen wrote:
> >>> I am doing a project similar to iptable using netfilter, currentl=
y =20
> >>> I want
> >>> to convert a IP address from 'long int' back to dotted address.
> >>>
> >>> I don't know whether there is some functions inside kernel or =20
> >>> netfilter
> >>> that could make that like using inet_ntoa() in <arpa/inet.h>
> >>
> >> How about NIPQUAD and NIPQUAD_FMT (for IPv4):
> >> http://lxr.linux.no/linux+v2.6.27.6/include/linux/kernel.h#L324
> >> http://lxr.linux.no/linux+v2.6.27.6/include/linux/kernel.h#L319
> >
> > In the latest tree, there are now "%pI4" and "%pI6" format options =
=20
> > for printk.
> >
> > For example:
> >
> > printk(KERN_DEBUG "Address: %pI4\n", &v4_addr);
>=20
> I've been watching this with some interest.  Is this API stable now?
>=20
> Is there a way to pass a pointer to a sockaddr and get printk() to =20
> figure out whether it's is an AF_INET or AF_INET6 address, and displa=
y =20
> it appropriately?

Nope, they're fixed-format currently.  They are pretty simple format
specifiers at this point.  I'm not sure if adding more dynamic behavior
is a good idea.

>=20
> Does it handle IPv6 scope IDs correctly?

Define correctly? ;-)

>=20
> Does it convert IPv6 mapped IPv4 addresses to dotted quad automatical=
ly?
>=20

Nope.

Quick summary:
%pI4 prints 4 decimal separated decimal numbers

%pI6 prints 8 16-bit hex numbers colon-separated=20
%pi6 omits the colons.

Harvey

