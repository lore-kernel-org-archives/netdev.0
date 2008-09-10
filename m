From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: [PATCH 1/1] niu: panic on reset
Date: Wed, 10 Sep 2008 10:01:42 -0700
Message-ID: <48C7FD76.2000206@sun.com>
References: <48C07564.3060306@Sun.COM>
 <20080908.132031.65821182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: Santwona.Behera@Sun.COM, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:34462 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbYIJRD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 13:03:27 -0400
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m8AH3PPQ029946
	for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 10:03:26 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0K6Z00601NQIVR00@fe-sfbay-09.sun.com>
 (original mail from Matheos.Worku@Sun.COM) for netdev@vger.kernel.org; Wed,
 10 Sep 2008 10:03:25 -0700 (PDT)
In-reply-to: <20080908.132031.65821182.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

>From: Santwona.Behera@Sun.COM
>Date: Thu, 04 Sep 2008 16:55:16 -0700
>
>[ Please learn how to hit the return key every 80 characters or so,
>  long lines are very difficult to read on text-only email clients
>  like the one I use.  Expecting auto-formatting and other beautifications
>  in email readers amongst kernel developers is a very bad idea. ]
>
>  
>
>>The reset_task function in the niu driver does not reset the
>>hardware fully. The buffer addresses and pointers are not being
>>reset/updated in the hardware and that leads to panic on reset.
>>
>>Signed-off-by: santwona.behera@sun.com <santwona.behera@sun.com>
>>    
>>
>
>This is way overkill just to fix this bug and it adds a new failure
>mode for the driver which is a seriously negative aspect to this fix.
>  
>
Dave,

Thanks for the feedback.
Instead of creating a new function, Santwona was borrowing an existing
logic from niu_change_mtu function. Rather than introducing a new
function and possibly a new failure mode, we were trying to re-use existing
logic, reducing the probability of a new bug.

Regards,
Matheos

>Instead, simply write a function which reloads the buffers addresses
>properly instead of calling the functions to free and reallocate all
>of these dynamic datastructures just to get those side effects.
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>  
>

