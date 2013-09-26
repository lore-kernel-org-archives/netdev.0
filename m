From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH]
Date: Thu, 26 Sep 2013 08:53:19 -0700
Message-ID: <1380210799.3165.187.camel@edumazet-glaptop>
References: <1380204582-27144-1-git-send-email-nikolay@redhat.com>
	  <1380204582-27144-2-git-send-email-nikolay@redhat.com>
	 <1380209227.3165.176.camel@edumazet-glaptop> <52445553.1030308@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com,
	vfalico@redhat.com
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:55392 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752685Ab3IZPxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 11:53:24 -0400
Received: by mail-pd0-f179.google.com with SMTP id v10so1333519pde.24
        for <netdev@vger.kernel.org>; Thu, 26 Sep 2013 08:53:23 -0700 (PDT)
In-Reply-To: <52445553.1030308@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-26 at 17:40 +0200, Nikolay Aleksandrov wrote:
> > 
> 1 question, I might be missing something but proto_ports_offset() gets the SPI
> with that 4 byte offset as is written in the comments, in every other case
> proto_ports_offset() is 0, so why would we want the SPI in the ->ports field ?
> And even then isn't it supposed to be 16 bits (2 bytes) and not 4, since we need
> to pass over "next header" (8 bits) and length (8 bits) ?

struct ip_auth_hdr {
        __u8  nexthdr;
        __u8  hdrlen;           /* This one is measured in 32 bit units! */
        __be16 reserved;
        __be32 spi;
        __be32 seq_no;          /* Sequence number */
        __u8  auth_data[0];     /* Variable len but >=4. Mind the 64 bit alignment! */
};

offsetof(spi, struct ...) = 4
