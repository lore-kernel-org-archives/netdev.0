From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: document undocumented active_slave sysfs entry.
Date: Mon, 26 Dec 2011 13:10:11 -0800
Message-ID: <20213.1324933811@death>
References: <1324901955-5816-1-git-send-email-nicolas.2p.debian@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: =?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:50407 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753219Ab1LZVKa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 16:10:30 -0500
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Mon, 26 Dec 2011 16:10:29 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pBQLADJW255230
	for <netdev@vger.kernel.org>; Mon, 26 Dec 2011 16:10:14 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pBQLADKs029827
	for <netdev@vger.kernel.org>; Mon, 26 Dec 2011 16:10:13 -0500
In-reply-to: <1324901955-5816-1-git-send-email-nicolas.2p.debian@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=C3=BCan 	<nicolas.2p.debian@free.fr> wrote:

>Signed-off-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
>cc: Jay Vosburgh <fubar@us.ibm.com>
>cc: Andy Gospodarek <andy@greyhouse.net>
>
>---
> Documentation/networking/bonding.txt |   14 ++++++++++++++
> 1 files changed, 14 insertions(+), 0 deletions(-)
>
>diff --git a/Documentation/networking/bonding.txt b/Documentation/netw=
orking/bonding.txt
>index 91df678..83b44c2 100644
>--- a/Documentation/networking/bonding.txt
>+++ b/Documentation/networking/bonding.txt
>@@ -196,6 +196,20 @@ or, for backwards compatibility, the option value=
=2E  E.g.,
>
> 	The parameters are as follows:
>
>+active_slave
>+
>+	Specifies the active slave for modes that support it (active-backup,
>+	balance-alb and balance-tlb). The possible values are one of the
>+	currently enslaved slaves. The selected slave must be up and the
>+	underlying link must be up too.

	I would phrase this a bit differently, also including the empty
string as a possible value:

	Specifies the new active slave for modes that support it
	(active-backup, balance-alb and balance-tlb).  Possible values
	are the name of any currently enslaved interface, or an empty
	string.  If a name is given, the slave must be up in order to be
	selected as the new active slave.  If an empty string is
	specified, the current active slave is cleared, and a new active
	slave is selected automatically.

>+	Note that this is only available through the sysfs interface. No mod=
ule
>+	parameter by that name exists.
=09
	"by this name" instead of "that".

>+	The default value is empty (no active slave). It will automatically =
be
>+	set every time an active slave is selected by normal bonding operati=
on.
>+	The current active slave can be read from this sysfs entry.

	I'd write this as:

	The normal value of this option is the name of the currently
	active slave, or the empty string if there is no active slave or
	the current mode does not use an active slave.

	With the above changes (or something pretty much equivalent) I'm
good with this, and you can add a signed-off for me.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
