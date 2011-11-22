From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: Re: MPLS for Linux kernel
Date: Tue, 22 Nov 2011 13:30:15 +0100
Message-ID: <4ECB95D7.7030702@dti2.net>
References: <CAFdo_mWE8wMB6QJt_DPi9Ou9OiayzV48URDq7KhKf+q8OfP+Gw@mail.gmail.com> <4ECA67C6.2080802@dti2.net> <20111121.132914.1611617296397809001.davem@davemloft.net> <4ECAA41C.9040007@dti2.net> <CAFdo_mXzqC_v5OkC6P012gFT_OmRO_yDTA0w96VhV-Lp3Hp7Fw@mail.gmail.com>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:54541 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851Ab1KVMgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 07:36:35 -0500
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v12.5.0)
	with ESMTP id md50019776987.msg
	for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 13:30:21 +0100
In-Reply-To: <CAFdo_mXzqC_v5OkC6P012gFT_OmRO_yDTA0w96VhV-Lp3Hp7Fw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El 22/11/2011 9:52, Igor Maravi=C4=87 escribi=C3=B3:
> What are the main reasons for You to think that mpls-linux is not
> ready to go upstream?
> As I said, I fixed a lot of bugs so code can be run with all the
> kernel hacking options enabled, without causing panics and oopses.
> Also fixed a lot of other things and added preprocessor if statements
> where code is intertwined with normal kernel code, so I'm sure that i=
t
> want break existing kernel compilation if the kernel is compiled
> without MPLS.
> Why would it be so hard to implemented it in terms of packet schedule=
r?

	First, please, don't top post.

	You keep insisting in that you fixed a lot of things, but you have pro=
vided a
git tree with just one big commit and say that have taken some of my pa=
tches on
it, could you please provide patches on TOP of the sourceforge code for=
 the
things that are not fixed there? And for the new features like the MIB =
stats
work that you have done? It seems to me that you have not noticed that =
while
fixing bugs I have reworked a lot of code to make it cleaner or simpler=
, simply
deleted it and fixed the style.

	What's needs to be done, and it's on my TODO list...

	The kernel code that is not commented out on the mpls-linux code when =
you build
the kernel it the shim layer and it's not done on purpose. This code wa=
s written
by James to be a generic feature of the networking layer. Now I am not =
sure that
it has any value keeping it and am for removing it.
	The other thing that probably I am going to remove is the labelspace s=
upport. I
don't see a use for it, and even Cisco doesn't implement it either that=
 I know.
	Then we must rework the netlink interface to make it cleaner and exten=
sible.
	Move the tunnel code to use the netlink interface and generic tunnel c=
ode.
	Check the dst's usages, there has been a lot of changes in the core ke=
rnel here
lately and I am not sure if we are using it correctly.
	Check the locking and RCU usage.
	Look for a way to remove the mpls_ptr from the net_device structure. T=
here's
code on another branch that does a radix-tree lookup for every packet b=
ut I
would like something simpler/lighter.

	As I said I am not for implementing MPLS support on top of the openvsw=
itch
stuff, that I don't know, like I don't think that we are going to port =
the
bridge, vlan, ip_gre, or even l2tp support over it, aren't we? :)

	I am committed to support this code as best as I can and try to get it=
 merged
but I would be nice if at least I can receive I confirmation of where w=
e are
heading on upstream.

	Regards,
		Jorge
