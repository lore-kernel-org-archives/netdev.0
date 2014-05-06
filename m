From: Tom Herbert <therbert@google.com>
Subject: Questions on sk_no_check implemenation
Date: Mon, 5 May 2014 19:34:40 -0700
Message-ID: <CA+mtBx_SK5LG8z_kTr5sHNhGQMBDgc+kpG49uyjgDM_eoK1hKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:61202 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933630AbaEFCel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 22:34:41 -0400
Received: by mail-ig0-f171.google.com with SMTP id c1so5636020igq.10
        for <netdev@vger.kernel.org>; Mon, 05 May 2014 19:34:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, I'm looking at sk_no_check implementation and am hoping to get
clarification on a couple of use cases.

1) In l2tp_core.c, if sk_no_check is set it looks like this will
completely bypass UDP checksum verification on RX even for packets
with nonzero checksums.

d2cf33616 (Benjamin LaHaise 2012-04-27 08:24:18 +0000 505) if
(sk->sk_no_check || skb_csum_unnecessary(skb))

I don't believe this is standards compliant and seems pretty risky
otherwise. What is the requirement here? Is this still needed?

2) The constant UDP_CSUM_NORCV was introduced for sunrpc and in fact
this looks like the only code that sets it. AFAICT the only effect
this would have would be to disable receive checksum verification in
L2TP as described above. What was the intent of UDP_CSUM_NORCV and why
was using this specific to sunrpc?

Thanks for  your help,
Tom
