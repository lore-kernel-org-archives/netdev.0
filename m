From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: MD5 SG fix
Date: Tue, 1 Jul 2008 14:48:31 -0700
Message-ID: <396556a20807011448m534c4c8dvf0b827f4cead4714@mail.gmail.com>
References: <396556a20805301217k293e5718h6bbf02bfe0683151@europa>
	 <20080701143943.426c9f24@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.238]:40530 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570AbYGAVsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 17:48:33 -0400
Received: by rv-out-0506.google.com with SMTP id k40so94328rvb.1
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2008 14:48:32 -0700 (PDT)
In-Reply-To: <20080701143943.426c9f24@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 1, 2008 at 2:39 PM, Stephen Hemminger <shemminger@vyatta.com> wrote:
> I would rather see the pool used less and the stack used more.
> Global context is more like FORTRAN common blocks.

Will do. My only concern was that it was 214 bytes which could easily
not be on the stack.

> My suggestion would be to have two hash functions, one that takes a block
> for the cases of TCP SYN, etc. and another that takes an skb for data packets.

You're probably right. If it works I'll break it out like that.

> You still need to have some of the places that reset sk_route_caps otherwise
> you will get TSO/GSO packets because of the resetting of route_caps after the SYN/ACK.

I've copied the hunks from [1] where sk_route_caps were added (not
just changed from ~GSO to ~(GSO|SG)). Hopefully those are the right
ones. I'll resend in a sec.


Cheers,

AGL

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
