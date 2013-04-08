From: Kay Sievers <kay@vrfy.org>
Subject: unix STREAM/SEQPACKET sockets and SO_PASSCRED race
Date: Mon, 8 Apr 2013 22:55:28 +0200
Message-ID: <CAPXgP106kvseQ_0ATmY38vPk1Sw+Y6+GBosJUcJ2YjfZKrHfzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:35804 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964854Ab3DHUzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 16:55:50 -0400
Received: by mail-wg0-f45.google.com with SMTP id x12so6390997wgg.12
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 13:55:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While checking the issues caused by:
  "af_unix: dont send SCM_CREDENTIAL when dest socket is NULL"
  http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=14134f6584212d585b310ce95428014b653dfaf6

which was later reverted by:
  http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=25da0e3e9d3fb2b522bc2a598076735850310eb1

Seems, if messages are sent by the client during the window between
accept() and setsockopt(SO_PASSCRED) on the server, the kernel will
not attach the credentials to the message.

The original change opened the race window significantly, but it seems
the window existed even before the change, it's just hard to hit.

Is there a way to race-free set up a connection on the server side
which has scm credentials enabled? If scm credential handling should
only be needed to be requested on the server side, is there any way to
do that?

If not, could we inherit/copy over the PASSCRED bit from the listen
socket to the connection socket. Servers could set the flag there to
receive it for the accepted connections?

Thanks,
Kay
