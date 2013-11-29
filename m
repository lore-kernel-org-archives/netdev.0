From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] af_packet: block BH in
 prb_shutdown_retire_blk_timer()
Date: Fri, 29 Nov 2013 16:11:57 -0500 (EST)
Message-ID: <20131129.161157.1747355120800232114.davem@davemloft.net>
References: <1385715203-14712-1-git-send-email-vfalico@redhat.com>
	<52985C21.7040303@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, netdev@vger.kernel.org, jstancek@redhat.com,
	willemb@google.com, phil@nwl.cc, edumazet@google.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545Ab3K2VL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 16:11:58 -0500
In-Reply-To: <52985C21.7040303@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri, 29 Nov 2013 10:19:29 +0100

> On 11/29/2013 09:53 AM, Veaceslav Falico wrote:
>> Currently we're using plain spin_lock() in
>> prb_shutdown_retire_blk_timer(),
>> however the timer might fire right in the middle and thus try to
>> re-aquire
>> the same spinlock, leaving us in a endless loop.
>>
>> To fix that, use the spin_lock_bh() to block it.
>>
>> CC: "David S. Miller" <davem@davemloft.net>
>> CC: Daniel Borkmann <dborkman@redhat.com>
>> CC: Willem de Bruijn <willemb@google.com>
>> CC: Phil Sutter <phil@nwl.cc>
>> CC: Eric Dumazet <edumazet@google.com>
>> Reported-by: Jan Stancek <jstancek@redhat.com>
>> Tested-by: Jan Stancek <jstancek@redhat.com>
>> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> 
> Fixes: f6fb8f100b80 ("af-packet: TPACKET_V3 flexible buffer
> implementation.")
> Acked-by: Daniel Borkmann <dborkman@redhat.com>

Applied and queued up for -stable, thanks!
