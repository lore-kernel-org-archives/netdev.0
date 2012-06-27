From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v2] l2tp: use per-cpu variables for u64_stats updates
Date: Wed, 27 Jun 2012 13:21:56 -0700
Message-ID: <4FEB6B64.5060708@hp.com>
References: <1340798457-28270-1-git-send-email-tparkin@katalix.com> <1340823810.26242.81.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Parkin <tparkin@katalix.com>, netdev@vger.kernel.org,
	David.Laight@ACULAB.COM, James Chapman <jchapman@katalix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:9266 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753353Ab2F0UV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 16:21:58 -0400
In-Reply-To: <1340823810.26242.81.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/27/2012 12:03 PM, Eric Dumazet wrote:
> On Wed, 2012-06-27 at 13:00 +0100, Tom Parkin wrote:
>> This patch fixes a race condition in l2tp when updating tunnel and
>> session statistics.  Previously it was possible for multiple threads
>> to concurrently call u64_stats_update*(), which lead to statistics
>> readers blocking forever.
>>
>> This race was discovered on an AMD64 SMP machine running a 32bit
>> kernel.  Running "ip l2tp" while sending data over an Ethernet
>> pseudowire resulted in an occasional soft lockup in
>> u64_stats_fetch_begin() called from l2tp_nl_session_send().
>>
>> For safe lockless update of l2tp stats, data is now stored in per-cpu
>> variables.  These per-cpu datasets are then summed at read time via.
>> an extra helper function l2tp_stats_copy() which has been added to
>> l2tp_core.c.
>>
>
> Do we really need 64bits stats on 32bit arches for l2tp ?

It is a question of the speed of the communications more than the 
bitness of the processor no?

rick jones
