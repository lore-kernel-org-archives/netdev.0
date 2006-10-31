From: netdev@weary.nl
Subject: sendmsg, descriptors and no content
Date: Tue, 31 Oct 2006 23:01:01 +0100
Message-ID: <20061031220101.GA3545@colo.weary.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from [72.9.228.82] ([72.9.228.82]:61927 "EHLO the.weary.nl")
	by vger.kernel.org with ESMTP id S1423675AbWJaWBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 17:01:04 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,


When I use sendmsg to send descriptors from one process to another using
unix-sockets I need to include at least one byte of normal data for the
descriptors to be send (using the iovec structure). The same code worked
fine on openbsd (ie. filedescriptors could be send without normal data).
If no normal data is included sendmsg will return 0, as if all data is
send correctly.


Is this difference on purpose? If so, why?


Regards,
Hylke


ps.
The current behaviour is because unix_stream_sendmsg in af_unix.c will
not do anything if len=0.

