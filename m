From: Jesse Gross <jesse@nicira.com>
Subject: Re: [net-next PATCH 1/3] qlge: Restoring the vlan setting.
Date: Mon, 25 Oct 2010 17:56:57 -0700
Message-ID: <AANLkTinr5fHjgPNieYjJuegU2EKWiQG00rAeatZV_=3w@mail.gmail.com>
References: <1288023473-31490-1-git-send-email-ron.mercer@qlogic.com>
	<1288023473-31490-2-git-send-email-ron.mercer@qlogic.com>
	<20101025.120739.104054830.davem@davemloft.net>
	<20101025194632.GA3545@linux-ox1b.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ying Ping Lok <ying.lok@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42847 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab0JZA47 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 20:56:59 -0400
Received: by wyf28 with SMTP id 28so4046256wyf.19
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 17:56:58 -0700 (PDT)
In-Reply-To: <20101025194632.GA3545@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 25, 2010 at 12:46 PM, Ron Mercer <ron.mercer@qlogic.com> wr=
ote:
> +static void qlge_restore_vlan(struct ql_adapter *qdev)
> +{
> + =A0 =A0 =A0 qlge_vlan_rx_register(qdev->ndev, qdev->vlgrp);
> +
> + =A0 =A0 =A0 if (qdev->vlgrp) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 vid;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (vid =3D 0; vid < VLAN_N_VID; vid++=
) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!vlan_group_get_dev=
ice(qdev->vlgrp, vid))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continu=
e;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 qlge_vlan_rx_add_vid(qd=
ev->ndev, vid);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +}

Using vlan groups within a driver is now deprecated.  I realize that
this is just a bug fix but it would nice if we can avoid introducing
more code around vlan groups.  Of course, fully switching the driver
over to use the new vlan model would be even nicer.
