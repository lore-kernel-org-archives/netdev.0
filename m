From: Li Yu <raise.sail@gmail.com>
Subject: A misbehavior of handling TCP out of band data ?
Date: Thu, 3 Mar 2011 15:24:07 +0000
Message-ID: <AANLkTinEBm1WuS9nRv3UcyoL4MJwBsqbukXUcUjHZQgU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f51.google.com ([74.125.83.51]:52160 "EHLO
	mail-gw0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758305Ab1CCPYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 10:24:08 -0500
Received: by gwb15 with SMTP id 15so621608gwb.10
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 07:24:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

        In my words, if we did not turn on SO_OOBINLINE at receiver,
any OOB bytes do not have to be read from regular TCP byte stream.

        But in below extreme case: the sender process have a loop to
send 1 OOB byte 'O' and 1 byte normal data 'D', the receiver ignore
all OOB data, so if OOB feature works well, the receiver should
receive 'D' only, However, in fact, the receiver still can see OOB
bytes by recv() syscall without MSG_OOB flag.

        I found that we may send "ODODODODODOD...." in a tcp segment,
and tcp_sendmsg() has no special code to avoid this.

        Well, I know that it seem that above case is too extreme to
use in actual environment, but above is simplified from our actual
scenario.

        Anyway, I think that overwriting or skip previous OOB bytes is
acceptable, but leave them in regular TCP byte stream likely is a bug.
En, probably, the disabled SO_OOBINLINE just is a feature of receiver
side, sender do not need to have to guarantee it?

        Thanks.

Yu
