From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][XFRM] Optimize policy dumping
Date: Mon, 04 Dec 2006 10:37:15 -0500
Message-ID: <1165246635.3643.6.camel@localhost>
References: <1165158707.3517.92.camel@localhost>
	 <45741386.5070002@trash.net> <1165238776.3664.40.camel@localhost>
	 <45742825.8040004@trash.net>  <45742964.9000905@trash.net>
	 <1165240725.3664.72.camel@localhost>  <1165241100.3664.75.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.227]:58317 "EHLO
	nz-out-0102.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S937030AbWLDPhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 10:37:21 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1884360nze
        for <netdev@vger.kernel.org>; Mon, 04 Dec 2006 07:37:19 -0800 (PST)
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <1165241100.3664.75.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-04-12 at 09:05 -0500, jamal wrote:
> Patrick,
> 
> Your approach is much cleaner. Let me give these a few tests then
> I will repost later today; forget about the callback approach for now.
> 

I have just applied the policy patch; havent compiled or tested (the
setup takes me a while to put together). But by staring, I am seeing
that you will end up with the same thing of sending a NULL or the same
entry twice.

Consider a simple hypothetical test. You have one one entry in the 
xfrm_policy_inexact table that matches. It happens to be the fifth out
of 10 elements. You find it at the 5th iteration. At the sixth iteration
you send it and last becomes null. 

All the way down, you call func with a NULL entry. You could add a check
to make sure it only gets invoked when last is not null, but the result
is in such a case, you will never send a 0 count element. I am sure
there could be other tricky scenarios like this that could be
constructed.

Thoughts.

cheers,
jamal

