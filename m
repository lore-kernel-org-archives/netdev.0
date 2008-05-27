From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] [CCID-3]: Remove ugly RTT-sampling history lookup
Date: Tue, 27 May 2008 06:36:51 -0700 (PDT)
Message-ID: <20080527.063651.236273094.davem@davemloft.net>
References: <1211877167-10995-4-git-send-email-gerrit@erg.abdn.ac.uk>
	<1211877167-10995-5-git-send-email-gerrit@erg.abdn.ac.uk>
	<1211877167-10995-6-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41003
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757277AbYE0Ngz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 09:36:55 -0400
In-Reply-To: <1211877167-10995-6-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 27 May 2008 09:32:45 +0100

> This removes the RTT-sampling function tfrc_tx_hist_rtt(), since
> 
>  1. it suffered from complex passing of return values (the return value both
>     indicated successful lookup while the value doubled as RTT sample);
> 
>  2. when for some odd reason the sample value equalled 0, this triggered a bug
>     warning about "bogus Ack", due to the ambiguity of the return value;
> 
>  3. on a passive host which has not sent anything the TX history is empty and
>     thus will lead to unwanted "bogus Ack" warnings such as
>     ccid3_hc_tx_packet_recv: server(e7b7d518): DATAACK with bogus ACK-28197148
>     ccid3_hc_tx_packet_recv: server(e7b7d518): DATAACK with bogus ACK-26641606.
> 
> The fix is to replace the implicit encoding by performing the steps manually.
> 
> Furthermore, the "bogus Ack" warning has been removed, since it can actually be
> triggered due to several reasons (network reordering, old packet, (3) above),
> hence it is not very useful.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This mixes bug fixes with cleanups, and also conflicts because I'm
not applying the hctx prefix changes.

Look, if you want to make the member names shorter, shorten the post-
prefix part of the name, instead of getting rid of the useful prefix
part.
