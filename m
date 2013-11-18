From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Revert "af-packet: Use existing netdev reference
 for bound sockets"
Date: Mon, 18 Nov 2013 13:03:10 -0500 (EST)
Message-ID: <20131118.130310.1183708218770881544.davem@davemloft.net>
References: <1384760425-37658-1-git-send-email-noureddine@aristanetworks.com>
	<5289D745.5020200@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: noureddine@aristanetworks.com, willemb@google.com, phil@nwl.cc,
	edumazet@google.com, netdev@vger.kernel.org,
	greearb@candelatech.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48647 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468Ab3KRSDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 13:03:15 -0500
In-Reply-To: <5289D745.5020200@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 18 Nov 2013 10:00:53 +0100

> On 11/18/2013 08:40 AM, Salam Noureddine wrote:
>> This reverts commit 827d978037d7d0bf0860481948c6d26ead10042f
>> ("af-packet: Use existing netdev reference for bound sockets")
>>
>> The patch introduced a race condition between packet_snd and
>> packet_notifier when a net_device is being unregistered. In the case
>> of
>> a bound socket, packet_notifier can drop the last reference to the
>> net_device and packet_snd might end up sending a packet over a freed
>> net_device.
> 
> So there's no other workaround possible like e.g. setting a flag in
> struct packet_sock so that in case our netdevice goes down, we just
> set the flag and if set, we return with -ENXIO in send path?
> Reverting this would decrease performance for everyone as we would
> then do the lookup every time we send a packet again.

Agreed, we should try first to find a reasonable fix instead of just
doing a knee-jerk revert of this change.

Thanks.
