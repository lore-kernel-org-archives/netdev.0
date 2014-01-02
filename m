From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] sctp: Remove outqueue empty state
Date: Thu, 2 Jan 2014 15:40:56 -0500
Message-ID: <20140102204056.GD7526@hmsreliant.think-freely.org>
References: <1388691584-11211-1-git-send-email-vyasevich@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46708 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752629AbaABUlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 15:41:09 -0500
Content-Disposition: inline
In-Reply-To: <1388691584-11211-1-git-send-email-vyasevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 02, 2014 at 02:39:44PM -0500, Vlad Yasevich wrote:
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

Acked-by: Neil Horman <nhorman@tuxdriver.com>
Nice work Vlad.
Neil
