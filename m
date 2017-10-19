From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: do not peel off an assoc from one netns to
 another one
Date: Thu, 19 Oct 2017 13:16:48 +0100 (WEST)
Message-ID: <20171019.131648.412950159699220691.davem@davemloft.net>
References: <e637d68ce6f4f94dce8cb30c647e672ebb1f0b7b.1508253970.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        chunwang@redhat.com, syzkaller@googlegroups.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48836 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753143AbdJSMRA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 08:17:00 -0400
In-Reply-To: <e637d68ce6f4f94dce8cb30c647e672ebb1f0b7b.1508253970.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue, 17 Oct 2017 23:26:10 +0800

> Now when peeling off an association to the sock in another netns, all
> transports in this assoc are not to be rehashed and keep use the old
> key in hashtable.
> 
> As a transport uses sk->net as the hash key to insert into hashtable,
> it would miss removing these transports from hashtable due to the new
> netns when closing the sock and all transports are being freeed, then
> later an use-after-free issue could be caused when looking up an asoc
> and dereferencing those transports.
> 
> This is a very old issue since very beginning, ChunYu found it with
> syzkaller fuzz testing with this series:
> 
>   socket$inet6_sctp()
>   bind$inet6()
>   sendto$inet6()
>   unshare(0x40000000)
>   getsockopt$inet_sctp6_SCTP_GET_ASSOC_ID_LIST()
>   getsockopt$inet_sctp6_SCTP_SOCKOPT_PEELOFF()
> 
> This patch is to block this call when peeling one assoc off from one
> netns to another one, so that the netns of all transport would not
> go out-sync with the key in hashtable.
> 
> Note that this patch didn't fix it by rehashing transports, as it's
> difficult to handle the situation when the tuple is already in use
> in the new netns. Besides, no one would like to peel off one assoc
> to another netns, considering ipaddrs, ifaces, etc. are usually
> different.
> 
> Reported-by: ChunYu Wang <chunwang@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
