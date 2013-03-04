From: Yannick Koehler <yannick@koehler.name>
Subject: Multicast/Broadcast enhancement: SKB read-only with copy-on-write
Date: Mon, 4 Mar 2013 10:29:22 -0500
Message-ID: <CAJ4BwwGs2FebA0jgedDxxmQEXSV=g2B07KBgu4C+0nigLbyvnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:45751 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757041Ab3CDP3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 10:29:23 -0500
Received: by mail-ie0-f180.google.com with SMTP id bn7so6369960ieb.11
        for <netdev@vger.kernel.org>; Mon, 04 Mar 2013 07:29:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

  Recently I was working into the kernel area where the code handle
broadcast/multicast in bridge logical interface for example.  It seems
today inevitable that when we flood, the bridge code has to duplicate
the full SKB, metadata as well as data, in order to transmit to each
link under it.  I was wondering if there was way for the SKB system to
support copy-on-write, such that, from a starting point, the SKB would
be "frozen" into a read-only mode and then if someone wants to modify
the SKB metadata/data it is done in a way to preserve the original SKB
memory, as to ensure that after the SKB has been transmitted over that
particular link, it can also be used without a full memory copy to be
sent to subsequent link, simultaneously on multi-core/mutli-interface
system.

  I am wondering at what level such work would be consider, is it
relatively easy, does Linux have anything like that, is it major work,
since pretty much everyone expect SKB data to be writable (like
skb_may_pull could be used to obtain a specific client SKB version
area).  It would probably require a new field in the SKB to indicate
that this is a read-only/copy-on-write version of a specific "original
SKB".

  Anyway, just wanted some thoughts/opinions on the topic regarding
the scale of such a change.

--
Yannick Koehler
