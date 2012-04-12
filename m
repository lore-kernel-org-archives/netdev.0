From: Alexandru Copot <alex.mihai.c@gmail.com>
Subject: RFC udp: improve __udp4_lib_lookup performance
Date: Thu, 12 Apr 2012 16:35:03 +0300
Message-ID: <CAHG7+CAt_YjxUp6+u9J47Ti1HA6hh_UkRMWQsXw4AsbEkvCu7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:64962 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933154Ab2DLNfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 09:35:03 -0400
Received: by iagz16 with SMTP id z16so2811209iag.19
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 06:35:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UDP uses 2 hashtables for fast socket lookup. First hash uses port as
a lookup key and the second one uses (port, addr).

When an UDP packet is received, the destination socket must be found to
deliver it. If there are many UDP sockets bound to INADDR_ANY, 2 hash
searches are made in the second hash: first one looks for the pair
(dest address, dest port) but doesn't find the socket; the second search
finds the socket by hashing (INADDR_ANY, dest port).

Those 2 searches can be avoided and a lot of time saved if instead we
searched directly in the first hash.

We could count the number of INADDR_ANY bound UDP sockets and
make only one search when that value is above a certain threshold. However,
if there are also sockets bound on a specific address, the second hash
won't be used and that might hurt performance for this case.

What is your opinion on this ? Would the performance gained by
counting INADDR_ANY bound sockets outweigh the loss in performance
for the case of mixed INADDR_ANY/specific address bound sockets ?

Alexandru Copot
