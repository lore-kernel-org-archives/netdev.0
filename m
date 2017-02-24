From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: deny peeloff operation on asocs with threads
 sleeping on it
Date: Fri, 24 Feb 2017 11:11:14 -0500 (EST)
Message-ID: <20170224.111114.542899448539607425.davem@davemloft.net>
References: <e3adb3f22270407764cfbeb1adb7e4c95cf42cbb.1487800862.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        vyasevich@gmail.com, nhorman@tuxdriver.com, lucien.xin@gmail.com,
        alex.popov@linux.com, ben@decadent.org.uk
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36808 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750934AbdBXQLT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 11:11:19 -0500
In-Reply-To: <e3adb3f22270407764cfbeb1adb7e4c95cf42cbb.1487800862.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Thu, 23 Feb 2017 09:31:18 -0300

> commit 2dcab5984841 ("sctp: avoid BUG_ON on sctp_wait_for_sndbuf")
> attempted to avoid a BUG_ON call when the association being used for a
> sendmsg() is blocked waiting for more sndbuf and another thread did a
> peeloff operation on such asoc, moving it to another socket.
> 
> As Ben Hutchings noticed, then in such case it would return without
> locking back the socket and would cause two unlocks in a row.
> 
> Further analysis also revealed that it could allow a double free if the
> application managed to peeloff the asoc that is created during the
> sendmsg call, because then sctp_sendmsg() would try to free the asoc
> that was created only for that call.
> 
> This patch takes another approach. It will deny the peeloff operation
> if there is a thread sleeping on the asoc, so this situation doesn't
> exist anymore. This avoids the issues described above and also honors
> the syscalls that are already being handled (it can be multiple sendmsg
> calls).
> 
> Joint work with Xin Long.
> 
> Fixes: 2dcab5984841 ("sctp: avoid BUG_ON on sctp_wait_for_sndbuf")
> Cc: Alexander Popov <alex.popov@linux.com>
> Cc: Ben Hutchings <ben@decadent.org.uk>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
> Hi, please consider this one for -stable too. Thanks

Applied and queued up for -stable, thanks.
