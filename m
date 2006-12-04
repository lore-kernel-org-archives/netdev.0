From: jamal <hadi@cyberus.ca>
Subject: Re: [XFRM] Optimize SA dumping
Date: Mon, 04 Dec 2006 08:55:02 -0500
Message-ID: <1165240502.3664.67.camel@localhost>
References: <1165163610.3517.96.camel@localhost>
	 <4574164B.1000505@trash.net> <1165238866.3664.43.camel@localhost>
	 <4574251C.8000906@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.239]:17463 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S936864AbWLDNzH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 08:55:07 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1861397nze
        for <netdev@vger.kernel.org>; Mon, 04 Dec 2006 05:55:07 -0800 (PST)
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4574251C.8000906@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-04-12 at 14:39 +0100, Patrick McHardy wrote:
...
...
> 4. iteration:
> 
> We have send_x = NULL and last_x != NULL, so send_x != last_x,
> leading to dump(NULL, ...)
> 

Ok, that is a very easy fix i.e just have 
         (send_x && send_x != last_x) 
as is done when the loop is exited. I thought i did that.

But i dont know if i even wanna fix that; consider the callback approach
i mentioned earlier.

> > In any case, if i go the done callback approach, I can get rid of all
> > this tracking thing ...
> 
> I need to read your other mail first before commenting on this :)

There is one key thing to observe: 
The count parameter is only used by pfkey; this is because the RFC
requires that we set the last entry to zero. So all that counting done
in the original codes first loop (which is huge overhead if you have a
large number of rules) is just so that we can achieve that ;->

By doing a callback, we move the burden of storing any state to pfkey
and free xfrm.


cheers,
jamal

