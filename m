From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Implement limits on hop by hop and
 destination options
Date: Fri, 12 May 2017 11:38:47 -0400 (EDT)
Message-ID: <20170512.113847.1389407948502066394.davem@davemloft.net>
References: <1494451999-19031-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kafai@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34976 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756738AbdELPit (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 11:38:49 -0400
In-Reply-To: <1494451999-19031-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 10 May 2017 14:33:19 -0700

> RFC 2460 (IPv6) defines hop by hop options and destination options
> extension headers. Both of these carry a list of TLVs which is
> only limited by the maximum length of the extension header (2048
> bytes). By the spec a host must process all the TLVs in these
> options, however these could be used as a fairly obvious
> denial of service attack. I think this could in fact be
> a significant DOS vector on the Internet, one mitigating
> factor might be that many FWs drop all packets with EH (and
> obviously this is only IPv6) so an Internet wide attack might not
> be so effective (yet!).
> 
> By my calculation, the worse case packet with TLVs in a standard
> 1500 byte MTU packet that would be processed by the stack contains
> 1282 invidual TLVs (including pad TLVS) or 724 two byte TLVs. I
> wrote a quick test program that floods a whole bunch of these
> packets to a host and sure enough there is substantial time spent
> in ip6_parse_tlv. These packets contain nothing but unknown TLVS
> (that are ignored), TLV padding, and bogus UDP header with zero
> payload length.
 ...
> Default values are set to 8 for options counts, and set to INT_MAX
> for maximum length. Note the choice to limit options to 8 is an
> arbitrary guess (roughly based on the fact that the stack supports
> three HBH options and just one destination option).

So the maximum number of TLVs we could process is some function of the
option count limit, and the number of padding TLVs that can be stuffed
alongside of those 8 non-padding options?
