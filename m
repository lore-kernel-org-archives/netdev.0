From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Trying to ping from a subinterface.
Date: Mon, 2 Jun 2014 17:35:54 -0700
Message-ID: <20140602173554.1dc77101@nehalam.linuxnetplumber.net>
References: <538CE2CA.9060806@us.thalesgroup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: CLOSE Dave <Dave.Close@us.thalesgroup.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:55595 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933234AbaFCAf6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 20:35:58 -0400
Received: by mail-pd0-f174.google.com with SMTP id r10so3957937pdi.33
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 17:35:57 -0700 (PDT)
In-Reply-To: <538CE2CA.9060806@us.thalesgroup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2 Jun 2014 13:47:06 -0700
CLOSE Dave <Dave.Close@us.thalesgroup.com> wrote:

> On Fedora 20 x86_64.
>=20
> According to "man ping", ping should work from a subinterface specify=
ing
> either the interface name or its address:
>=20
> > -I interface
> >    interface is either an address, or an interface name.  If inter=E2=
=80=90
> >    face is an address, it sets source address to  specified  inter=E2=
=80=90
> >    face address.  If interface in an interface name, it sets source
> >    interface to specified interface.
>=20
> I've got a subinterface and I'm trying to ping from it.
>=20
> > # ifconfig eth3:sub1
> > eth3:sub1: flags=3D4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
> >        inet 172.17.30.143  netmask 255.255.254.0  broadcast 172.17.=
31.255
> >        ether 90:e2:ba:34:46:41  txqueuelen 1000  (Ethernet)
> >        device memory 0xdc7e0000-dc800000
>=20
> If I ping from the address, it works as specified. If I specify the
> interface name instead, I see:
>=20
> > # ping -I eth3:sub1 172.17.30.1
> > ping: SO_BINDTODEVICE: Invalid argument
>=20
> Investigating a little deeper:
>=20
> > # strace ping -I eth3:sub1 172.17.30.1
> > execve("/usr/bin/ping", ["ping", "-I", "eth3:sub1", "172.17.30.1"],=
 [/* 38 vars */]) =3D 0
> > ...
> > setsockopt(4, SOL_SOCKET, SO_BINDTODEVICE, "eth3:sub1\0", 13) =3D -=
1 ENODEV (No such device)
> > ...
> > +++ exited with 2 +++
>=20
> Any thoughts?

Interface aliases (sub interfaces) aren't real interfaces in Linux.
They are a deprecated way of doing multiple addresses on the same devic=
e.
Aliases aren't real devices, they don't behave like devices, and they
only are useful with ancient tools like ifconfig.

Don't use them unless you have to deal with systems older than 10 years=
=2E
