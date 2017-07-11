From: Balaji Foss <balajig.foss@gmail.com>
Subject: Re: Regarding xfrm state search with destination address as wildcard mask
Date: Tue, 11 Jul 2017 16:58:16 +0530
Message-ID: <CAJ4ZP5T3xaxvYAS03LAg0e1bEqKMcnH2iMwhBwGyAZqGyhnJ=Q@mail.gmail.com>
References: <CAJ4ZP5QhmV89K_EfF19B_wjAbOYBNj_62dZksJNCwHUAHVmGvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: steffen.klassert@secunet.com,
        Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:36521 "EHLO
        mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752175AbdGKL2S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 07:28:18 -0400
Received: by mail-vk0-f46.google.com with SMTP id y70so62691291vky.3
        for <netdev@vger.kernel.org>; Tue, 11 Jul 2017 04:28:18 -0700 (PDT)
In-Reply-To: <CAJ4ZP5QhmV89K_EfF19B_wjAbOYBNj_62dZksJNCwHUAHVmGvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Any help on this query is greatly appreciated.

Thanks,
  - Balaji

On Thu, Jul 6, 2017 at 12:21 PM, Balaji Foss <balajig.foss@gmail.com> wrote:
> Hi All,
>
> Im trying to implement IPSec for ospfv3 as per RFC4552 on Linux kernel
> version 3.16.39.
> Requirement is to support IPsec encryption/authentication for ospfv3 traffic.
> As of now, this can be achieved by following set of SA and SP rules.
>
> ip xfrm state add src :: dst ff02::5 proto ah spi 0x401 mode transport
> auth "hmac(sha1)" 0x12345678123456781234567812345678
> ip xfrm state add src :: dst ff02::6 proto ah spi 0x401 mode transport
> auth "hmac(sha1)" 0x12345678123456781234567812345678
> ip xfrm state add src <sip> dst <dst_ip> proto ah spi 0x401 mode
> transport auth "hmac(sha1)" 0x12345678123456781234567812345678
> ip xfrm state add src <dst_ip> dst <sip> proto ah spi 0x401 mode
> transport auth "hmac(sha1)" 0x12345678123456781234567812345678
>
> ip xfrm policy add dir out src <sip> dst 0::0/0 dev e101-049-0 proto
> ospf priority 2147483648 tmpl  proto ah spi 0x401 mode transport level
> use
> ip xfrm policy add dir in src 0::0/0 dst 0::0/0 dev e101-049-0 proto
> ospf priority 2147483648 tmpl proto ah spi 0x401 mode transport level
> use
>
>
> One can notice that it needs four SA rules to achieve IPsec for single
> OSPF interface.
> Instead of these four rules, can we have a single rule with DIP as
> wild card mask and the xfrm state search as based on SPI ,family and
> proto alone?
>
> As of now, the API "__xfrm_state_lookup"  search based on
> SPI,family,proto and dest_addr.  Is there any way I can achieve the SA
> lookup without dest_addr and only with SPI,family and proto alone?
>
> Any help or pointers is greatly appreciated.
>
> Regards
> Bala
