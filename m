From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Correct use of private socket queue and pskb_copy
Date: Mon, 16 Feb 2009 10:32:42 +0100
Message-ID: <17e3a8f80902160132m65d2c18dkc70f4bb362a2b7c8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:62004 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756256AbZBPJco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 04:32:44 -0500
Received: by bwz5 with SMTP id 5so2939509bwz.13
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2009 01:32:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am working on a TCP modification that requires private copies of the
affected SKBs and the memory cannot safely be freed before ACK is
received. To solve this, I have created a new queue in the
sock-struct, intialized in sock_init_data and sk_clone, and then use
the queue in the following order:

* tcp_transmit_skb is called
* If the skb shall be modified, creates a copy using pskb_copy
* Modifies the skb and places the copy on "my" queue
* ACK is received, kernel works through "my" queue and removes SKBs
that can be removed.

However, there is something I can't figure out and that stops this
solution from working. After placing the copy of the SKB on the queue,
after a while I see that its memory is modified. The sequence numbers
change to corrupted values, next/prev-pointers break and so forth.My
question is, does anyone have any idea on what modifies the memory or
what I might have done wrong? As far as I can see, the queue is
initialized correctly and I have not found anywhere in the code that
modifies any of the affected areas of the copied SKB (code that is run
after it is created).

Thanks in advance for any help.

-Kristian
