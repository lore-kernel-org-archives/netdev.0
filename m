From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: bonding driver - how to recognize the active slave
Date: Thu, 20 Dec 2012 14:52:15 -0800
Message-ID: <1356043935.21834.3504.camel@edumazet-glaptop>
References: <BA0B6857ABCA474FB07F0DA6F50A3077918B2450@MTRDAG01.mtl.com>
	 <1356038370.21834.3315.camel@edumazet-glaptop>
	 <CAJZOPZLOj2QCWN75hAsQnmB=YiSGRhdhzf4ODhAD-QoU+Y0ZGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Erez Shitrit <erezsh@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33678 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814Ab2LTWwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 17:52:17 -0500
Received: by mail-pa0-f43.google.com with SMTP id fb10so2410853pad.16
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 14:52:17 -0800 (PST)
In-Reply-To: <CAJZOPZLOj2QCWN75hAsQnmB=YiSGRhdhzf4ODhAD-QoU+Y0ZGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-21 at 00:21 +0200, Or Gerlitz wrote:
> On Thu, Dec 20, 2012 at 11:19 PM, Eric Dumazet <erdnetdev@gmail.com> =
wrote:
> > cat /sys/class/net/bond0/bonding/active_slave
>=20
> sure, I think Erez would like to know that from within a network
> device kernel code, e.g maybe register to netdev kernel events and on
> the event of bonding fail-over identify the active slave for
> active-backup mode, etc.

OK, but then why a network driver should be aware of this bonding
detail ?

It seems part of this commit could be reverted,
ie setting IFF_SLAVE_INACTIVE again.

commit 2d7011ca79f1a8792e04d131b8ea21db179ab917
Author: Jiri Pirko <jpirko@redhat.com>
Date:   Wed Mar 16 08:46:43 2011 +0000

    bonding: get rid of IFF_SLAVE_INACTIVE netdev->priv_flag
   =20
    Since bond-related code was moved from net/core/dev.c into bonding,
    IFF_SLAVE_INACTIVE is no longer needed. Replace is with flag "inact=
ive"
    stored in slave structure
   =20
    Signed-off-by: Jiri Pirko <jpirko@redhat.com>
    Reviewed-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
    Signed-off-by: David S. Miller <davem@davemloft.net>
