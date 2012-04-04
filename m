From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] scpt: Allow struct sctp_event_subscribe to grow
 without breaking binaries
Date: Wed, 04 Apr 2012 18:05:52 -0400 (EDT)
Message-ID: <20120404.180552.936202389292040147.davem@davemloft.net>
References: <20120404081753.GA5124@canuck.infradead.org>
	<4F7C5204.9040703@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757028Ab2DDWGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 18:06:08 -0400
In-Reply-To: <4F7C5204.9040703@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 04 Apr 2012 09:52:04 -0400

> On 04/04/2012 04:17 AM, Thomas Graf wrote:
>> getsockopt(..., SCTP_EVENTS, ...) performs a length check and returns
>> an error if the user provides less bytes than the size of struct
>> sctp_event_subscribe.
>> 
>> Struct sctp_event_subscribe needs to be extended by an u8 for every
>> new event or notification type that is added.
>> 
>> This obviously makes getsockopt fail for binaries that are compiled
>> against an older versions of <net/sctp/user.h> which do not contain
>> all event types.
>> 
>> This patch changes getsockopt behaviour to no longer return an error
>> if not enough bytes are being provided by the user. Instead, it
>> returns as much of sctp_event_subscribe as fits into the provided buffer.
>> 
>> This leads to the new behavior that users see what they have been aware
>> of at compile time.
>> 
>> The setsockopt(..., SCTP_EVENTS, ...) API is already behaving like this.
>> 
>> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied, but I had to fix the Subject to read "sctp: " not "scpt: " :-)
