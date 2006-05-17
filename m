From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] reno sacked_out count fix
Date: Tue, 16 May 2006 21:40:11 -0700 (PDT)
Message-ID: <20060516.214011.132715124.davem@davemloft.net>
References: <8dd26e70605160224i44bbaa8ei93eede75e71f6665@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, francesco@net.infocom.uniroma1.it,
	andrea.baiocchi@uniroma1.it
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:56242
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751245AbWEQEkI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 May 2006 00:40:08 -0400
To: angelo.castellani+lkml@gmail.com
In-Reply-To: <8dd26e70605160224i44bbaa8ei93eede75e71f6665@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Angelo P. Castellani" <angelo.castellani+lkml@gmail.com>
Date: Tue, 16 May 2006 11:24:00 +0200

> Using NewReno, if a sk_buff is timed out and is accounted as lost_out,
> it should also be removed from the sacked_out.
> 
> This is necessary because recovery using NewReno fast retransmit could
> take up to a lot RTTs and the sk_buff RTO can expire without actually
> being really lost.
> 
> left_out = sacked_out + lost_out
> in_flight = packets_out - left_out + retrans_out
> 
> Using NewReno without this patch, on very large network losses,
> left_out becames bigger than packets_out + retrans_out (!!).
> 
> For this reason unsigned integer in_flight overflows to 2^32 - something.

Thanks for your analysis and fix, I will apply it.

This pseudo-SACK for Reno scheme could probably use some changes.  For
example, one idea Herbert Xu had was to maintain the pseudo-SACKs in
the actual TAG bits of the TCP_SKB_CB() as if we saw real SACKs.  But
I am concerned that since we have to be careful not to trust those
pseudo-SACK bits too much, it could actually make the code more
complicated not less complicated.
