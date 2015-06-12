From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: allow authenticating DATA chunks that are bundled
 with COOKIE_ECHO
Date: Fri, 12 Jun 2015 13:24:08 -0400
Message-ID: <557B15B8.6050500@gmail.com>
References: <ca8fca62141ed9e108170919cdc12bdb09cdda73.1434043704.git.marcelo.leitner@gmail.com> <20150611.172745.1400543460379693397.davem@davemloft.net> <20150612112640.GA22204@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vn0-f47.google.com ([209.85.216.47]:34541 "EHLO
	mail-vn0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982AbbFLRYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 13:24:12 -0400
In-Reply-To: <20150612112640.GA22204@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/12/2015 07:26 AM, Neil Horman wrote:
> On Thu, Jun 11, 2015 at 05:27:45PM -0700, David Miller wrote:
>> From: mleitner@redhat.com
>> Date: Thu, 11 Jun 2015 14:49:46 -0300
>>
>>> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
>>>
>>> Currently, we can ask to authenticate DATA chunks and we can send DATA
>>> chunks on the same packet as COOKIE_ECHO, but if you try to combine
>>> both, the DATA chunk will be sent unauthenticated and peer won't accept
>>> it, leading to a communication failure.
>>>
>>> This happens because even though the data was queued after it was
>>> requested to authenticate DATA chunks, it was also queued before we
>>> could know that remote peer can handle authenticating, so
>>> sctp_auth_send_cid() returns false.
>>>
>>> The fix is whenever we set up an active key, re-check send queue for
>>> chunks that now should be authenticated. As a result, such packet will
>>> now contain COOKIE_ECHO + AUTH + DATA chunks, in that order.
>>>
>>> Reported-by: Liu Wei <weliu@redhat.com>
>>> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
>>
>> Vlad/Neil, please review.
>>
> 
> sorry Dave, though I had sent email on that already.
> 
> I had an initial concern that there could be a race in which a previous
> iteration of sctp_outq_flush would move some chunks to a packet, but not flush
> it to the network layer yet (due to not being full), and that would result in
> the same condition.  But since this only happens with a COOKIE_ECHO chunk (which
> is a control chunk), we should be ok, as those are sent immediately.

Neil.  I don't think this race can happen since outq manipulation always happens under
a socket lock and so do socket options.  So, we are guaranteed that outq will not change
in this case.

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> 
