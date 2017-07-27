From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: fix the check for _sctp_walk_params and
 _sctp_walk_errors
Date: Thu, 27 Jul 2017 00:03:38 -0700 (PDT)
Message-ID: <20170727.000338.219284921836754840.davem@davemloft.net>
References: <81a6fb647ad305525c840eae623c41b7ba52c975.1501057499.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com, glider@google.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33604 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750836AbdG0HDj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 03:03:39 -0400
In-Reply-To: <81a6fb647ad305525c840eae623c41b7ba52c975.1501057499.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Wed, 26 Jul 2017 16:24:59 +0800

> Commit b1f5bfc27a19 ("sctp: don't dereference ptr before leaving
> _sctp_walk_{params, errors}()") tried to fix the issue that it
> may overstep the chunk end for _sctp_walk_{params, errors} with
> 'chunk_end > offset(length) + sizeof(length)'.
> 
> But it introduced a side effect: When processing INIT, it verifies
> the chunks with 'param.v == chunk_end' after iterating all params
> by sctp_walk_params(). With the check 'chunk_end > offset(length)
> + sizeof(length)', it would return when the last param is not yet
> accessed. Because the last param usually is fwdtsn supported param
> whose size is 4 and 'chunk_end == offset(length) + sizeof(length)'
> 
> This is a badly issue even causing sctp couldn't process 4-shakes.
> Client would always get abort when connecting to server, due to
> the failure of INIT chunk verification on server.
> 
> The patch is to use 'chunk_end <= offset(length) + sizeof(length)'
> instead of 'chunk_end < offset(length) + sizeof(length)' for both
> _sctp_walk_params and _sctp_walk_errors.
> 
> Fixes: b1f5bfc27a19 ("sctp: don't dereference ptr before leaving _sctp_walk_{params, errors}()")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable, thanks.
