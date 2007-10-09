From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 0/6][NET-2.6.24] Consolidate private allocations in seq files
Date: Tue, 09 Oct 2007 19:50:41 +0400
Message-ID: <470BA351.3070208@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:40644 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753219AbXJIPxN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 11:53:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many (very many) seq files in net/ allocate some private data
to use it later (mostly for iteration state). All this code
was obviously get using copy-paste method, so move it into
one place.

Almost all of these places either set this private to 0, or
keep uninitialized. Some places, however, pre-initialize this
area, but there are few of them.

The seq_open_private() call just opens the seq file with
allocated and set to zero area. The __seq_open_private() call
makes the same, but returns the allocated memory to the called
to be initialized later.

I didn't measure how much of the .text section this saves,
but I suspect a lot of :) As far as the code is concerned,
this set saves ~450 lines.

Such thing may be useful for any subsystem, but I found this
mostly in the networking code and fixed only it (for a while).

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
