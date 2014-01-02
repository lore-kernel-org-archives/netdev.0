From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: Remove outqueue empty state
Date: Thu, 02 Jan 2014 17:23:34 -0500 (EST)
Message-ID: <20140102.172334.1775225132082706633.davem@davemloft.net>
References: <1388691584-11211-1-git-send-email-vyasevich@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, jhs@mojatatu.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709AbaABWXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 17:23:35 -0500
In-Reply-To: <1388691584-11211-1-git-send-email-vyasevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Thu,  2 Jan 2014 14:39:44 -0500

> The SCTP outqueue structure maintains a data chunks
> that are pending transmission, the list of chunks that
> are pending a retransmission and a length of data in
> flight.  It also tries to keep the emtpy state so that
> it can performe shutdown sequence or notify user.
> 
> The problem is that the empy state is inconsistently
> tracked.  It is possible to completely drain the queue
> without sending anything when using PR-SCTP.  In this
> case, the empty state will not be correctly state as
> report by Jamal Hadi Salim <jhs@mojatatu.com>.  This
> can cause an association to be perminantly stuck in the
> SHUTDOWN_PENDING state.
> 
> Additionally, SCTP is incredibly inefficient when setting
> the empty state.  Even though all the data is availaible
> in the outqueue structure, we ignore it and walk a list
> of trasnports.
> 
> In the end, we can completely remove the extra empty
> state and figure out if the queue is empty by looking
> at 3 things:  length of pending data, length of in-flight
> data, and exisiting of retransmit data.  All of these
> are already in the strucutre.
> 
> Reported-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>

Applied, but:

> + */ 
      ^^

Trailing whitespace which I had to fixup when applying this.

THanks.
