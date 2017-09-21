From: Tom Herbert <tom@quantonium.net>
Subject: Re: [PATCH net-next 12/14] gtp: Configuration for zero UDP checksum
Date: Thu, 21 Sep 2017 15:41:03 -0700
Message-ID: <CAPDqMepsh9eD9eBVr0rp5h1WTdpVwncc7D3_SXDjQBcqm_pqcg@mail.gmail.com>
References: <20170919003904.5124-1-tom@quantonium.net> <20170919003904.5124-13-tom@quantonium.net>
 <20170918.212445.1680068602644706922.davem@davemloft.net> <CALx6S35NP_BJ8oHwjkOZkNYJa=g7hWeUiNMZ5WNj-2FQaksCeQ@mail.gmail.com>
 <20170921015522.sv5netrlcj5vebys@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tom Herbert <tom@herbertland.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Rohit Seth <rohit@quantonium.net>
To: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f170.google.com ([209.85.128.170]:57211 "EHLO
        mail-wr0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751738AbdIUWlE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 18:41:04 -0400
Received: by mail-wr0-f170.google.com with SMTP id r74so5601236wrb.13
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 15:41:04 -0700 (PDT)
In-Reply-To: <20170921015522.sv5netrlcj5vebys@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 20, 2017 at 6:55 PM, Harald Welte <laforge@gnumonks.org> wrote:
> Hi Tom,
>
> On Wed, Sep 20, 2017 at 11:09:29AM -0700, Tom Herbert wrote:
>> On Mon, Sep 18, 2017 at 9:24 PM, David Miller <davem@davemloft.net> wrote:
>> > From: Tom Herbert <tom@quantonium.net>
>> >> Add configuration to control use of zero checksums on transmit for both
>> >> IPv4 and IPv6, and control over accepting zero IPv6 checksums on
>> >> receive.
>> >
>> > I thought we were trying to move away from this special case of allowing
>> > zero UDP checksums with tunnels, especially for ipv6.
>>
>> I don't have a strong preference either way. I like consistency with
>> VXLAN and foo/UDP, but I guess it's not required. Interestingly, since
>> GTP only carries IP, IPv6 zero checksums are actually safer here than
>> VXLAN or GRE/UDP.
>
> Just for the record: I don't care either way and I defer to the kernel
> networking developers to decide if they want to have zero UDP checksum
> in GTP or not.
>
> The 3GPP specs don't say anything about UDP checksums.  So there's no
> requirement to use them, and hence operation without UDP checksums
> should be compliant.  Cisco GTP implementation has udp checksumming
> configurable, so other implementations also seem to provide both ways.
>
> In general, I would argue one wants UDP checksumming of GTP in all
> setups, as while the inner IP packet might be protected, the GTP header
> itself is not, and that's what contains important data suhc as the TEID
> (Tunnel Endpoint ID).  But that's of course just my personal opinion,
> and I'm not saying we should prevent people from using lower protection
> if that's what they want.
>
The tradeoffs and requirements of zero UDP6 checksums are discussed at
length in RFC6935 and RFC6936. Given other implementations make it
configurable it should also be here.

Tom

> --
> - Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
> ============================================================================
> "Privacy in residential applications is a desirable marketing option."
>                                                   (ETSI EN 300 175-7 Ch. A6)
