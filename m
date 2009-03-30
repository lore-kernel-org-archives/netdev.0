From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/2] kaweth: Fix locking to be SMP-safe
Date: Mon, 30 Mar 2009 10:58:28 -0500
Message-ID: <49D0EC24.4080206@lwfinger.net>
References: <49d00512.XAF19LdpY1dlK6+U%Larry.Finger@lwfinger.net> <200903300828.45337.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost04.isp.att.net ([207.115.11.54]:61156 "EHLO
	fmailhost04.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752567AbZC3P7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 11:59:16 -0400
In-Reply-To: <200903300828.45337.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum wrote:
> Am Montag 30 M=E4rz 2009 01:32:34 schrieb Larry Finger:
>> On an SMP system, the following message is printed. The patch below =
gets
>> fixes the problem.
>=20
> Thanks for this report and the patch. I think, however that it introd=
uces
> unneeded locking. It seems to me that we should be fine if we fix
> kaweth_start_xmit(). That code assumes that it is called with interru=
pts
> off and under a spinlock. Is that incorrect?

You are correct in that only the locking in kaweth_start_xmit() needs t=
o be
changed to lock out the other CPU's. In my testing under extreme condit=
ions (X
server over the network), the interface stalled with no logged messages=
=2E My
other changes in the locking were an unsuccessful attempt to fix that a=
nd have
been removed. Version 2 of the patches will be sent after I finish test=
ing.

Thanks,

Larry


