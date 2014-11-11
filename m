From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Tracking errors in netdevice (and other?) notifiers
Date: Tue, 11 Nov 2014 18:39:29 +0100
Message-ID: <CACna6ryUOhQSyjiqKwpOZPPRKC42ufB1aSqAwOrMdTJDnqiD-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:51326 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbaKKRja convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 12:39:30 -0500
Received: by mail-ie0-f178.google.com with SMTP id rp18so11582270iec.23
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 09:39:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

During development of wireless driver I got this poor meaning error:
# ifconfig wlan0_1 up
ifconfig: SIOCSIFFLAGS: Device or resource busy

I've quickly tracked it down to the __dev_open [0]. Then it became wors=
e.
In my case call_netdevice_notifiers returned 32785 which was
translated by notifier_to_errno to the -16 (-EBUSY).

Unfortunately I couldn't track call_netdevice_notifiers. It iterates
over a chain (list) of nameless notifiers (struct notifier_block). I
didn't have a chance to e.g. print a name of notifier that returned an
error.

Is there some trick to do that? To track notifiers and find a code
responsible for the chain error?

In my case it wasn't too hard, because there are only few places in
the kernel registering for NETDEV_PRE_UP. So I checked all of them and
found the guilty one. But I still would like to know if there is some
smart way.


[0] http://lxr.free-electrons.com/source/net/core/dev.c?v=3D3.17#L1268

--=20
Rafa=C5=82
