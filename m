From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] tcp: receive-side per route dctcp
 handling
Date: Mon, 31 Aug 2015 12:34:16 -0700 (PDT)
Message-ID: <20150831.123416.266144212097794732.davem@davemloft.net>
References: <cover.1441027533.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbbHaTeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 15:34:17 -0400
In-Reply-To: <cover.1441027533.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 31 Aug 2015 15:58:43 +0200

> Original cover letter:
> 
>   Currently, the following case doesn't use DCTCP, even if it should:
> 
>     - responder has f.e. cubic as system wide default
>     - 'ip route congctl dctcp $src' was set
> 
>   Then, DCTCP is NOT used if a DCTCP sender attempts to connect from a
>   host in the $src range: ECT(0) is set, but listen_sk is not dctcp, so
>   we fail the INET_ECN_is_not_ect sanity check.
> 
>   We also have to examine the dst used for the SYN/ACK reply to make
>   this case work.
> 
>   In order to minimize additional cost, store the 'ecn is must have'
>   information is the dst_features field.
> 
>   The set targets -next instead of -net since this doesn't seem to be a
>   serious bug and to give the change more soak time until it hits linus
>   tree.
> 
> v1 -> v2:
>  - Addressed Dave's feedback, not exposing any bits to user space
>  - Added patch 3 to reject incorrect configurations
>  - Rest as is, rebased and retested

Series applied, thanks Daniel.
