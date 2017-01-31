From: David Laight <David.Laight@ACULAB.COM>
Subject: sock_create_kern() and network namespace reference counts
Date: Tue, 31 Jan 2017 15:41:23 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0276D58@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.181]:54704 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750916AbdAaPmO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 10:42:14 -0500
Received: from 1cYaYh-0004eh-TA by out6b.electric.net with emc1-ok (Exim 4.87)
        (envelope-from <David.Laight@ACULAB.COM>)
        id 1cYaYh-0004iS-U4
        for netdev@vger.kernel.org; Tue, 31 Jan 2017 07:41:27 -0800
Received: from [213.249.233.130] (helo=AcuExch.aculab.com)
        by out6b.electric.net with esmtps (TLSv1:AES128-SHA:128)
        (Exim 4.87)
        (envelope-from <David.Laight@ACULAB.COM>)
        id 1cYaYh-0004eh-TA
        for netdev@vger.kernel.org; Tue, 31 Jan 2017 07:41:27 -0800
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 26abe1437 changed sock_create_kern() so that it stopped
holding a reference to the network namespace.
The rational seemed to be 'to allow to stop it' (presumably 'be deleted').
Prior to this change some kernel paths used sk_change_net() (etc) to
change the namespace after the socket was created.

If the socket doesn't hold a reference to the namespace, what actually
happens when the namespace is deleted?
I can't help feeling there is an indirection through a stale pointer
just waiting to happen.

Clearly the driver calling sock_create_kern() could itself call get_net()
but that could still leave issues with sockets that get into TIME_WAIT
states.
Even that is easier said than done, a non-GPL driver cannot call put_net()
to drop a reference.

While I can imagine that there are some 'special' sockets that don't
need to hold the reference, it seems unlikely that it is true for all
users of sock_create_kern().

	David
