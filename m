From: Kevin Wilson <wkevils@gmail.com>
Subject: ntohs() and htons() usgae in the network stack
Date: Wed, 10 Jun 2009 17:08:12 +0300
Message-ID: <55c333c0906100708q1b0be2ffkc80c2f3258f0e681@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:45422 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755639AbZFJOIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 10:08:10 -0400
Received: by pzk1 with SMTP id 1so796644pzk.33
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2009 07:08:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I will appreciate if someone can explain this mystery to me:

While debugging some kernel module, I added printing of ports.
I had printer both ntohs() and htons() of a port number. I got the same
values. Since I used low port number, I decided to find out from which
port there begins to be a difference. So I tried to write in a simple
kernel module this loop, which tests all ports up till 65536 (since
port number is 16 bit wide):
	...
	int i;
	for (i=0;i<65536;i++)
	 if (ntohs(i) != htons(i))
		printk("found inequality: ntohs(i) != htons(i)\n");

And when running it it did **not** find such a port where ntohs(i) !=
htons ( "found inequality:.. was **not** printed).

So I wondered : when is ntohs(i) != htons(i) ?
Are they always equal (I doubt it); or am I missing something silly here?

I am testing it on x86_64 Intel machine (little endian).
Rgs,
Kevin
