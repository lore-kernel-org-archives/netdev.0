From: Michael Chan <mchan@broadcom.com>
Subject: Re: Linux kernel commit breaks IPMI on iface downing
Date: Fri, 4 Sep 2015 01:29:59 -0700
Message-ID: <1441355399.8556.15.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <CAJPaPGU2_68J4BZanm+Lw3O+WTiwO3swegh5grP5Bn-XprLOwg@mail.gmail.com>
	 <1439515834.7684.24.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <CAJPaPGUsyHwaaTuUGcV5BMsSDcw1T7XQ9GVy5KwsMao3k8u+Kg@mail.gmail.com>
	 <CAJPaPGU=8mWhrOSKRMnZjEULsBcO4PWkCsyUEfLfpY+cktyK_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=cp1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <harish.patil@qlogic.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?S=E9bastien?= Bocahu <sbu@reportlinker.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:61059 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665AbbIDIaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 04:30:11 -0400
In-Reply-To: <CAJPaPGU=8mWhrOSKRMnZjEULsBcO4PWkCsyUEfLfpY+cktyK_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-09-04 at 09:55 +0200, S=E9bastien Bocahu wrote:=20
> Hi,
>=20
> Any chance this behaviour gets fixed, with either a new firmware or a
> workaround in the kernel ?
>=20

As I said earlier, when we call bnx2_shutdown_chip(), we inform the
firmware that the driver is shutting down.  The firmware should know
that there is IPMI firmware and the link needs to stay up.

In the older driver, we would also call bnx2_set_power_state() which
would send some additional messages to the firmware before putting the
device in D3hot.  May be these messages are required by the firmware to
keep the link up.  Harish, please check with your firmware team.
Thanks.
