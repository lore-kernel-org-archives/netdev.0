From: Tom Herbert <therbert@google.com>
Subject: Bug in computing data_len in tcp_sendmsg?
Date: Wed, 30 Nov 2011 17:48:04 -0800
Message-ID: <CA+mtBx8+sajFaCWqHRr+pY5EAHwN8G61v6cr-HydYhbbdxAgHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:60298 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753021Ab1LABsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 20:48:05 -0500
Received: by iage36 with SMTP id e36so1663535iag.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 17:48:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I believe that skb->data_len might no be computed correctly in
tcp_sendmsg.  Specifically, when skb_add_data_nocache (or
skb_add_data) is called skb->data_len is not updated (skb_put only
updates skb->len).  This results in the datalen in the head skbuf
being zero so any subsequent uses of the value lead to incorrect
results.  For instance, skb_headlen returns the length of the head
skbu data and not just that of the headers.  If I'm reading this
correctly, it's a pretty fundamental bug.

I don't have a fix for this yet.

Tom
