From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute: Properly handle protocol level diag module
 absence
Date: Mon, 10 Feb 2014 14:37:31 -0800
Message-ID: <20140210143731.34b73a78@nehalam.linuxnetplumber.net>
References: <52E7E990.7050501@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	=?ISO-8859-1?B?RnJhbudvaXMtWGF2aWVy?= Le Bail
	<fx.lebail@yahoo.com>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:47987 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260AbaBJWhf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 17:37:35 -0500
Received: by mail-pa0-f45.google.com with SMTP id lf10so6772370pab.18
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 14:37:34 -0800 (PST)
In-Reply-To: <52E7E990.7050501@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Jan 2014 21:32:00 +0400
Pavel Emelyanov <xemul@parallels.com> wrote:

> When *_diag module is missing in the kernel, the ss tool should go
> ad read legacry /proc/* files.
>=20
> This is the case when all *_diag stuff is missing, but in case the
> inet_diag.ko is loaded, but (tcp|udp)_diag.ko is not, the ss tool
> doesn't notice this and produces empty output. The reason for that
> is -- error from the inet_diag module (which means, that e.g. the
> udp_diag is missing) is reported in the NLMSG_DONE message body.
>=20
> That said, we need to check the NLMSG_DONE's message return code
> and act respectively.
>=20
> Reported-by: Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com>
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>=20

Silently ignoring the error seems wrong.
The fallback is good, but we should try and report the error so that
the user fixes the kernel config.
