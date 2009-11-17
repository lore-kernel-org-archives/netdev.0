From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v6 4/7 RFC] TCPCT part 1d: define TCP cookie
 option, extend existing struct's
Date: Tue, 17 Nov 2009 05:41:15 -0500
Message-ID: <4B027DCB.9060403@gmail.com>
References: <4B01BF65.1010203@gmail.com>	<4B01CD8D.1000305@gmail.com>	<4B01D17C.4010407@gmail.com> <20091116.191522.178198674.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, joe@perches.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f226.google.com ([209.85.217.226]:32934 "EHLO
	mail-gx0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754839AbZKQKlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 05:41:12 -0500
Received: by gxk26 with SMTP id 26so1637170gxk.1
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2009 02:41:18 -0800 (PST)
In-Reply-To: <20091116.191522.178198674.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 16 Nov 2009 23:26:04 +0100
> 
>> So adding DATA to SYN packets might be problematic for part of our tcp stack.
> 
But is outside the scope of anything in this part 1 patch series.

Of course, part 2 will dispense with the request_sock entirely....


> I can almost guarentee it won't work.  For one thing getting a SACK
> response to a SYN+DATA packet will explode quite nicely for one thing.
> 
Sounds like a lack of error handling to me....  Never trust that sensible
data will appear from the network!


> A lot of the other retransmit queue handling would need to be audited
> as well.  So much code assumes that if we see sent data in the
> retransmit queue, there won't be SYN or SYN+ACK things in there to
> contend with.
> 
Well then, it's a darn tootin' good thing that the code in part 1g doesn't
send SYNACK data in the retransmit queue, and the code in 1d (here) doesn't
include the SYNACK data in the tcp_minisocks.c clone.  The prominent
comment might have been a sign to the careful reviewer:

+		 * as it differs for each connection.  There is no need to
+		 * copy any s_data_payload stored at the original socket.
