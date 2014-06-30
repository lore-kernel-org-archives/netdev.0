From: David Laight <David.Laight@ACULAB.COM>
Subject: [PATCH net-next 0/3] net: sctp: Optimisations to sctp command queue
 code
Date: Mon, 30 Jun 2014 13:00:57 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1726977C@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David S. Miller" <davem@davemloft.net>
To: Network Development <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:56221 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752609AbaF3NB4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 09:01:56 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12098-05 for <netdev@vger.kernel.org>;
 Mon, 30 Jun 2014 14:01:47 +0100 (BST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These 3 patches optimise the code that processes sctp's command queue.
(A list of 'tasks' to be performed after the rest of the chunk processing.)

1) Inline all the functions from command.c
2) Remove the memset() calls used to zero a word-sized union.
3) Use pointers instead of array indexes.

The combined changes reduce the code size (amd64) by a few kb.

I'm not 100% convinced that the zeroing done in patch 2 is needed at all.
On BE systems it is likely to generate more code than on LE ones.
In fact it might be best to change the union to only contain 'long' sized
items.

	David
