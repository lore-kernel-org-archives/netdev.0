From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix multithreaded signal handling in unix recv
 routines
Date: Mon, 07 Mar 2011 15:31:37 -0800 (PST)
Message-ID: <20110307.153137.212682178.davem@davemloft.net>
References: <877hck43hs.fsf@sapphire.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: rweikusat@mobileactivedefense.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <877hck43hs.fsf@sapphire.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Date: Mon, 28 Feb 2011 14:50:55 +0000

> From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
> 
> The unix_dgram_recvmsg and unix_stream_recvmsg routines in
> net/af_unix.c utilize mutex_lock(&u->readlock) calls in order to
> serialize read operations of multiple threads on a single socket. This
> implies that, if all n threads of a process block in an AF_UNIX recv
> call trying to read data from the same socket, one of these threads
> will be sleeping in state TASK_INTERRUPTIBLE and all others in state
> TASK_UNINTERRUPTIBLE. Provided that a particular signal is supposed to
> be handled by a signal handler defined by the process and that none of
> this threads is blocking the signal, the complete_signal routine in
> kernel/signal.c will select the 'first' such thread it happens to
> encounter when deciding which thread to notify that a signal is
> supposed to be handled and if this is one of the TASK_UNINTERRUPTIBLE
> threads, the signal won't be handled until the one thread not blocking
> on the u->readlock mutex is woken up because some data to process has
> arrived (if this ever happens). The included patch fixes this by
> changing mutex_lock to mutex_lock_interruptible and handling possible
> error returns in the same way interruptions are handled by the actual
> receive-code.
> 
> Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>

Looks good, applied, thanks.
