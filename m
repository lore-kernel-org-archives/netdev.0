From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] net: Do not include padding in TCP GRO checksum
Date: Thu, 14 Nov 2013 21:34:14 -0800
Message-ID: <5285B256.9060605@gmail.com>
References: <20131115011413.7090.9349.stgit@ahduyck-fpga.jf.intel.com> <20131114.230821.139211038449295349.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	herbert@gondor.apana.org
To: David Miller <davem@davemloft.net>, alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:38548 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752653Ab3KOFk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 00:40:26 -0500
Received: by mail-pd0-f170.google.com with SMTP id q10so3041455pdj.1
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 21:40:25 -0800 (PST)
In-Reply-To: <20131114.230821.139211038449295349.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2013 08:08 PM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Thu, 14 Nov 2013 17:18:18 -0800
> 
>> I haven't had a chance to test this much yet and I am not that familiar
> 
> As Eric mentioned, unless you tested on big endian, chances are you
> didn't test this at all. :-)
> 

Actually I had tested it very breifly, but with Rx checksum offloads
still enabled.

> You're accessing the IPv4/IPv6 length fields without converting it
> to CPU endian.

Yeah, I realized that after I hit the BUG_ON in skb_checksum.

I'll be submitting a v2 in the morning with some tested code.  The only
difficult part is that I don't have any devices that generate
CHECKSUM_COMPLETE.  I think if there is padding I will probably just
fall back to the CHECKSUM_NONE case since that seems to be what
IPv4/IPv6 does in their receive calls when they call pskb_trim_rcsum on
padded frames.

Thanks,

Alex
