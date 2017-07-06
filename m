From: Balaji Foss <balajig.foss@gmail.com>
Subject: Regarding xfrm state search with destination address as wildcard mask
Date: Thu, 6 Jul 2017 12:21:56 +0530
Message-ID: <CAJ4ZP5QhmV89K_EfF19B_wjAbOYBNj_62dZksJNCwHUAHVmGvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f196.google.com ([209.85.217.196]:35685 "EHLO
        mail-ua0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753091AbdGFGv6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 02:51:58 -0400
Received: by mail-ua0-f196.google.com with SMTP id j53so797940uaa.2
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 23:51:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

Im trying to implement IPSec for ospfv3 as per RFC4552 on Linux kernel
version 3.16.39.
Requirement is to support IPsec encryption/authentication for ospfv3 traffic.
As of now, this can be achieved by following set of SA and SP rules.

ip xfrm state add src :: dst ff02::5 proto ah spi 0x401 mode transport
auth "hmac(sha1)" 0x12345678123456781234567812345678
ip xfrm state add src :: dst ff02::6 proto ah spi 0x401 mode transport
auth "hmac(sha1)" 0x12345678123456781234567812345678
ip xfrm state add src <sip> dst <dst_ip> proto ah spi 0x401 mode
transport auth "hmac(sha1)" 0x12345678123456781234567812345678
ip xfrm state add src <dst_ip> dst <sip> proto ah spi 0x401 mode
transport auth "hmac(sha1)" 0x12345678123456781234567812345678

ip xfrm policy add dir out src <sip> dst 0::0/0 dev e101-049-0 proto
ospf priority 2147483648 tmpl  proto ah spi 0x401 mode transport level
use
ip xfrm policy add dir in src 0::0/0 dst 0::0/0 dev e101-049-0 proto
ospf priority 2147483648 tmpl proto ah spi 0x401 mode transport level
use


One can notice that it needs four SA rules to achieve IPsec for single
OSPF interface.
Instead of these four rules, can we have a single rule with DIP as
wild card mask and the xfrm state search as based on SPI ,family and
proto alone?

As of now, the API "__xfrm_state_lookup"  search based on
SPI,family,proto and dest_addr.  Is there any way I can achieve the SA
lookup without dest_addr and only with SPI,family and proto alone?

Any help or pointers is greatly appreciated.

Regards
Bala
