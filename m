From: ivl@krasu.ru (Igor V. Liferenko)
Subject: A question about linux/net/ipv4/ipcomp.c
Date: Fri, 21 Jul 2006 11:26:58 +0800
Message-ID: <7t7j27iqnx.fsf@seba.krasu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from seba.krasu.ru ([80.250.188.21]:47254 "EHLO seba.krasu.ru")
	by vger.kernel.org with ESMTP id S964829AbWGUD1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2006 23:27:00 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, everyone.

I'm having fun reading RFC's and looking through linux source code for
implementation examples.

What I'm not able to understand is this piece of code :

union {
		struct iphdr	iph;
		char 		buf[60];
} tmp_iph;

and corresponding RFC 791 statement : "The maximal internet header is
60 octets."

Would you please say why it's 60, and not 52?

Well, what I came up with is this :

RFC791: "The option-length octet counts the option-type octet and the
option-length octet as well as the option-data octets". [i.e.
options' total length may be up to 2^8/8 octets (32)]. Then, header
lenght without options is 20 octets. So, a maximum header length is
32+20=52 octets. RFC791: "Internet Header Length is the length of the
internet header in 32 bit words..." 52 octets is 52*8 bits and it's a
multiple of 32.

Thanks in advance
