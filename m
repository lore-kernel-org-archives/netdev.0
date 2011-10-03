From: matt d <mattjd@gmail.com>
Subject: x25: remote-triggerable heap overflow in call user data processing
Date: Mon, 3 Oct 2011 16:23:10 +1300
Message-ID: <CA+nUz_K-mWFbFbSGKDFDGUufQmDA9+qW-0=1BDJ9QGe2Dxi-3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:41539 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754887Ab1JCDXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Oct 2011 23:23:10 -0400
Received: by gyg10 with SMTP id 10so2995478gyg.19
        for <netdev@vger.kernel.org>; Sun, 02 Oct 2011 20:23:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refer to the x25 packet layer's handling of incoming call user data,
namely at these two locations, in x25_rx_call_request and
x25_state1_machine:
https://github.com/mirrors/linux/blob/master/net/x25/af_x25.c#L1039
https://github.com/mirrors/linux/blob/master/net/x25/x25_in.c#L126

Call user data from an incoming message is copied into
(make)x25->calluserdata.cuddata buffers, which are 128 bytes long.
However, the length copied is based on the remaining message length,
and is not limited to the output buffer size. This allows a remote
attacker to overflow data onto the heap.

There is an appropriate constant defined for the length, but it
seemingly isn't used there:
https://github.com/mirrors/linux/blob/master/include/net/x25.h#L104

It seems this issue was noticed some time ago:
http://www.spinics.net/lists/linux-x25/msg00043.html
http://patchwork.ozlabs.org/patch/23917/
...however nothing was done about the bigger problem.

I have written a simple exploit for this vulnerability if it needs to
be posted, however I think the problem is pretty straightforward to
see as-is.

- Matthew Daley
