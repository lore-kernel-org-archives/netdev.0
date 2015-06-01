From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix child sockets to use system default
 congestion control if not set
Date: Sun, 31 May 2015 21:50:10 -0700 (PDT)
Message-ID: <20150531.215010.362645685156777606.davem@davemloft.net>
References: <1432921627-10515-1-git-send-email-ncardwell@google.com>
	<5568AED9.2030905@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, netdev@vger.kernel.org, fw@strlen.de,
	glenn.judd@morganstanley.com, stephen@networkplumber.org,
	edumazet@google.com, ycheng@google.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45416 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbbFAEuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 00:50:11 -0400
In-Reply-To: <5568AED9.2030905@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 29 May 2015 20:24:25 +0200

> On 05/29/2015 07:47 PM, Neal Cardwell wrote:
>> Linux 3.17 and earlier are explicitly engineered so that if the app
>> doesn't specifically request a CC module on a listener before the SYN
>> arrives, then the child gets the system default CC when the connection
>> is established. See tcp_init_congestion_control() in 3.17 or earlier,
>> which says "if no choice made yet assign the current value set as
>> default". The change ("net: tcp: assign tcp cong_ops when tcp sk is
>> created") altered these semantics, so that children got their parent
>> listener's congestion control even if the system default had changed
>> after the listener was created.
>>
>> This commit returns to those original semantics from 3.17 and earlier,
>> since they are the original semantics from 2007 in 4d4d3d1e8 ("[TCP]:
>> Congestion control initialization."), and some Linux congestion
>> control workflows depend on that.
>>
>> In summary, if a listener socket specifically sets TCP_CONGESTION to
>> "x", or the route locks the CC module to "x", then the child gets
>> "x". Otherwise the child gets current system default from
>> net.ipv4.tcp_congestion_control. That's the behavior in 3.17 and
>> earlier, and this commit restores that.
>>
>> Fixes: 55d8694fa82c ("net: tcp: assign tcp cong_ops when tcp sk is
>> created")
>> Cc: Florian Westphal <fw@strlen.de>
>> Cc: Daniel Borkmann <dborkman@redhat.com>
>> Cc: Glenn Judd <glenn.judd@morganstanley.com>
>> Cc: Stephen Hemminger <stephen@networkplumber.org>
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> 
> Ok, change looks good to me, thanks.
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied and queued up for -stable, thanks!
