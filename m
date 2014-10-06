From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: handle association restarts when the socket is
 closed.
Date: Mon, 06 Oct 2014 09:08:14 -0400
Message-ID: <5432943E.7000505@gmail.com>
References: <1412374580-22286-1-git-send-email-vyasevich@gmail.com> <20141006.002229.1370132762577292096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:43473 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462AbaJFNIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 09:08:17 -0400
Received: by mail-qg0-f43.google.com with SMTP id j107so3643399qga.16
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 06:08:17 -0700 (PDT)
In-Reply-To: <20141006.002229.1370132762577292096.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/2014 12:22 AM, David Miller wrote:
> From: Vladislav Yasevich <vyasevich@gmail.com>
> Date: Fri,  3 Oct 2014 18:16:20 -0400
> 
>> From: Vlad Yasevich <vyasevich@gmail.com>
>>
>> Currently association restarts do not take into consideration the
>> state of the socket.  When a restart happens, the current assocation
>> simply transitions into established state.  This creates a condition
>> where a remote system, through a the restart procedure, may create a
>> local association that is no way reachable by user.  The conditions
>> to trigger this are as follows:
>>   1) Remote does not acknoledge some data causing data to remain
>>      outstanding.
>>   2) Local application calls close() on the socket.  Since data
>>      is still outstanding, the association is placed in SHUTDOWN_PENDING
>>      state.  However, the socket is closed.
>>   3) The remote tries to create a new association, triggering a restart
>>      on the local system.  The association moves from SHUTDOWN_PENDING
>>      to ESTABLISHED.  At this point, it is no longer reachable by
>>      any socket on the local system.
>>
>> This patch addresses the above situation by moving the newly ESTABLISHED
>> association into SHUTDOWN-SENT state and bundling a SHUTDOWN after
>> the COOKIE-ACK chunk.  This way, the restarted associate immidiately
>> enters the shutdown procedure and forces the termination of the
>> unreachable association.
>>
>> Reported-by: David Laight <David.Laight@aculab.com>
>> Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
> 
> Applied, thanks.
> 
> Candidate for -stable?
> 

I say yes.  If this problem is triggered it is total pain to get the memory
clean-up.

-vlad
