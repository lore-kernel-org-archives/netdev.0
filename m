From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] tcp: use PRR to reduce cwin in CWR state
Date: Mon, 03 Sep 2012 14:34:33 -0400 (EDT)
Message-ID: <20120903.143433.1794691067153660874.davem@davemloft.net>
References: <1346643484-12947-1-git-send-email-ycheng@google.com>
	<1346643484-12947-3-git-send-email-ycheng@google.com>
	<CADVnQyma09UtSLusyQ6986uz2yfy-3xZ+mXrHfn1A2HO+3=X_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, nanditad@google.com, mattmathis@google.com,
	edumazet@google.com, netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49553 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756229Ab2ICSef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 14:34:35 -0400
In-Reply-To: <CADVnQyma09UtSLusyQ6986uz2yfy-3xZ+mXrHfn1A2HO+3=X_g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Mon, 3 Sep 2012 00:00:44 -0400

> On Sun, Sep 2, 2012 at 11:38 PM, Yuchung Cheng <ycheng@google.com> wrote:
>> Use proportional rate reduction (PRR) algorithm to reduce cwnd in CWR state,
>> in addition to Recovery state. Retire the current rate-halving in CWR.
>> When losses are detected via ACKs in CWR state, the sender enters Recovery
>> state but the cwnd reduction continues and does not restart.
>>
>> Rename and refactor cwnd reduction functions since both CWR and Recovery
>> use the same algorithm:
>> tcp_init_cwnd_reduction() is new and initiates reduction state variables.
>> tcp_cwnd_reduction() is previously tcp_update_cwnd_in_recovery().
>> tcp_ends_cwnd_reduction() is previously  tcp_complete_cwr().
>>
>> The rate halving functions and logic such as tcp_cwnd_down(), tcp_min_cwnd(),
>> and the cwnd moderation inside tcp_enter_cwr() are removed. The unused
>> parameter, flag, in tcp_cwnd_reduction() is also removed.
>>
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>

Applied to net-next
