From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: Don't allow mode change via sysfs with slaves
 present
Date: Thu, 17 Nov 2011 22:28:24 +0100
Message-ID: <4EC57C78.4040006@gmail.com>
References: <1321375482-8637-1-git-send-email-vfalico@redhat.com> <20111115170018.GB25132@gospo.rdu.redhat.com> <4EC2BC6D.9000304@gmail.com> <20111115193535.GC25132@gospo.rdu.redhat.com> <4EC2C550.6050805@gmail.com> <20111115204659.GE25132@gospo.rdu.redhat.com> <4EC3A64D.40405@gmail.com> <20111116220200.GF25132@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Veaceslav Falico <vfalico@redhat.com>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>, Guus Sliepen <guus@debian.org>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:37511 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752299Ab1KQV20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 16:28:26 -0500
Received: by wwe3 with SMTP id 3so4099135wwe.1
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 13:28:25 -0800 (PST)
In-Reply-To: <20111116220200.GF25132@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/11/2011 23:02, Andy Gospodarek a =E9crit :

<snip>

> I was looking at ifenslave 1.1.0-20.  If you look at Debian bug #6412=
50
> you will see a very similar report to what prompted Veaceslav to come=
 up
> with this patch and post it here.

I completely missed this version. I recently reinstalled my system and =
forgot to add unstable to=20
source.list.

> ifenslave-2.6 (1.1.0-20) unstable; urgency=3Dlow
>
>    * Use dashes consistently for bonding options in README.Debian.
>      Closes: #639244
>    * Enslave slaves only after fully setting up the master. Closes: #=
641250
>    * Add build-arch and build-indep targets to debian/rules.
>
>   -- Guus Sliepen<guus@debian.org>   Mon, 14 Nov 2011 11:36:21 +0100

Having a look at the change made to fix the bug described in #641250, I=
 anticipate it will cause=20
some regressions because some of the actions taken in setup_master must=
 be done after enslavement=20
and are now done before:

- primary must be set after mode (because only supported in some modes)=
 and after enslavement.
- primary_reselect should be set after mode (because only supported in =
some modes), after=20
enslavement and after primary.
- queue_id must be set after enslavement.
- active_slave must be set after mode and after enslavement.

I will prepare a -21 version.

<snip>

> Since this problem seems like a pretty major problem and now Debian,
> Fedora, RHEL, and Ubuntu all seem to have proper initialization scrip=
ts
> to handle it, I stand behind my original ACK.

You are right.

Acked-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

	Nicolas.
