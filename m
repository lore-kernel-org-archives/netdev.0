From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: do not loose window information if in
 rwnd_over
Date: Fri, 23 Dec 2016 14:01:59 -0500 (EST)
Message-ID: <20161223.140159.2291080991092269291.davem@davemloft.net>
References: <14d1eef1c9da4fcebc53d428a59ecaefab439b2c.1482510284.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        nhorman@tuxdriver.com, vyasevich@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48502 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753320AbcLWTCA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2016 14:02:00 -0500
In-Reply-To: <14d1eef1c9da4fcebc53d428a59ecaefab439b2c.1482510284.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Fri, 23 Dec 2016 14:29:02 -0200

> It's possible that we receive a packet that is larger than current
> window. If it's the first packet in this way, it will cause it to
> increase rwnd_over. Then, if we receive another data chunk (specially as
> SCTP allows you to have one data chunk in flight even during 0 window),
> rwnd_over will be overwritten instead of added to.
> 
> In the long run, this could cause the window to grow bigger than its
> initial size, as rwnd_over would be charged only for the last received
> data chunk while the code will try open the window for all packets that
> were received and had its value in rwnd_over overwritten. This, then,
> can lead to the worsening of payload/buffer ratio and cause rwnd_press
> to kick in more often.
> 
> The fix is to sum it too, same as is done for rwnd_press, so that if we
> receive 3 chunks after closing the window, we still have to release that
> same amount before re-opening it.
> 
> Log snippet from sctp_test exhibiting the issue:
> [  146.209232] sctp: sctp_assoc_rwnd_decrease: asoc:ffff88013928e000
> rwnd decreased by 1 to (0, 1, 114221)
> [  146.209232] sctp: sctp_assoc_rwnd_decrease:
> association:ffff88013928e000 has asoc->rwnd:0, asoc->rwnd_over:1!
> [  146.209232] sctp: sctp_assoc_rwnd_decrease: asoc:ffff88013928e000
> rwnd decreased by 1 to (0, 1, 114221)
> [  146.209232] sctp: sctp_assoc_rwnd_decrease:
> association:ffff88013928e000 has asoc->rwnd:0, asoc->rwnd_over:1!
> [  146.209232] sctp: sctp_assoc_rwnd_decrease: asoc:ffff88013928e000
> rwnd decreased by 1 to (0, 1, 114221)
> [  146.209232] sctp: sctp_assoc_rwnd_decrease:
> association:ffff88013928e000 has asoc->rwnd:0, asoc->rwnd_over:1!
> [  146.209232] sctp: sctp_assoc_rwnd_decrease: asoc:ffff88013928e000
> rwnd decreased by 1 to (0, 1, 114221)
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied.
