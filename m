From: Martin Sustrik <sustrik@250bpm.com>
Subject: Checking for closed TCP connection in kernel space
Date: Tue, 04 Jan 2011 16:16:43 +0100
Message-ID: <4D2339DB.2090603@250bpm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chrocht.moloch.sk ([62.176.169.44]:51553 "EHLO mail.moloch.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752960Ab1ADPPa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jan 2011 10:15:30 -0500
Received: from [10.9.1.2] (188-167-8-187.dynamic.chello.sk [188.167.8.187])
	by mail.moloch.sk (Postfix) with ESMTPSA id 2D6291800F83
	for <netdev@vger.kernel.org>; Tue,  4 Jan 2011 16:15:27 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I open a TCP socket in the kernel space (sock_create_kern). I connect or 
bind it, I send and receive data. Everything works as expected.

The problem is how to find out that the peer have closed the connection.

In user space you get 0 when calling recv() is such case. However, in 
kernel space kernel_recvmsg seems to return 0 anytime when there are no 
more data available. It doesn't return an error either.

Should I monitor the socket state using sk_state_change callback? But 
the callback seems to work in async manner, i.e. I can accidentally use 
closed socket before I get notified about the state change.

Any ideas?
Martin
