From: Ketan Kulkarni <ketkulka@gmail.com>
Subject: [Query] TCP TFO Query
Date: Tue, 11 Dec 2012 22:59:02 +0530
Message-ID: <CAD6NSj5Qv3n+0a2rdTaiCtUtT5DXZEE4-K3qxaVX+XMK6Q=SFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:57406 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753240Ab2LKRg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 12:36:59 -0500
Received: by mail-ie0-f182.google.com with SMTP id s9so13253167iec.41
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2012 09:36:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I am testing tcp tfo behavior with httping client and polipo server on 3.7rc-8

One observation from my TFO testing  -If for a connection server sends
a cookie to client, client always does TFO for subsequent connections.
This is ok.

If for some reason, server stops supporting TFO (either because server
got restarted without TFO support (in my case) or because path changed
and the nw node is dropping packet with unknown syn option or
stripping the option), client does not clear up its cookie cache. It
always sends data in syn and server never acks the syn-data and client
retransmits.

As per kernel code -if syn-data is not acked it is retransmitted
immediately - with the assumption first syn was dropped (but the
assumption server stopped supporting TFO might not have been
considered)

Will it be better to flush the cookie for this server and re-attempt
the cookie "negotiation" on subsequent connection than to retransmit
the data every time?

Your thoughts?

Thanks,
Ketan
