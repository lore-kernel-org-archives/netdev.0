From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip_tunnel: Fix dst ref-count.
Date: Wed, 26 Mar 2014 15:19:09 -0400 (EDT)
Message-ID: <20140326.151909.772278041679801312.davem@davemloft.net>
References: <1395637596-28064-1-git-send-email-pshelar@nicira.com>
	<20140324.152412.1501867662024898167.davem@davemloft.net>
	<CALnjE+rzAs4Wr=pmozyPAr=T3QHE=-8qRBf-U_fHMDqeWAE+GA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lucien.xin@gmail.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217AbaCZTTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 15:19:12 -0400
In-Reply-To: <CALnjE+rzAs4Wr=pmozyPAr=T3QHE=-8qRBf-U_fHMDqeWAE+GA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>
Date: Mon, 24 Mar 2014 12:36:41 -0700

> On Mon, Mar 24, 2014 at 12:24 PM, David Miller <davem@davemloft.net> wrote:
>> From: Pravin <pshelar@nicira.com>
>> Date: Sun, 23 Mar 2014 22:06:36 -0700
>>
>>> Commit 10ddceb22ba (ip_tunnel:multicast process cause panic due
>>> to skb->_skb_refdst NULL pointer) removed dst-drop call from
>>> ip-tunnel-recv.
>>>
>>> Following commit reintroduce dst-drop and fix the original bug by
>>> checking loopback packet before releasing dst.
>>> Original bug: https://bugzilla.kernel.org/show_bug.cgi?id=70681
>>>
>>> CC: Xin Long <lucien.xin@gmail.com>
>>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>>
>> I don't understand why only the GRE tunnel implementation needs the
>> check, whereas ipip and sit seem to have the same code associated
>> paths.
>>
> Multicast support is for GRE. The code is always been protected by
> CONFIG_NET_IPGRE_BROADCAST. So I do not understand how this applies to
> other tunnel protocol. Can you point me to the code you are worried
> about?

Ok, looks good, applied and queued up for -stable thanks!
