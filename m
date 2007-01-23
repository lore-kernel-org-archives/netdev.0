From: Dan Williams <dcbw@redhat.com>
Subject: Re: [RFC] airo.c: Description and function is not the same
Date: Tue, 23 Jan 2007 10:11:34 -0500
Message-ID: <1169565094.2777.9.camel@localhost.localdomain>
References: <45B35616.6040103@student.ltu.se>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49392 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751959AbXAWPKd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 10:10:33 -0500
To: Richard Knutsson <ricknu-0@student.ltu.se>
In-Reply-To: <45B35616.6040103@student.ltu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-01-21 at 13:01 +0100, Richard Knutsson wrote:
> Hello
> 
> In the tour of converting local definitions of boolean-type/values, I 
> ran into airo.c's description of ex decapsulate():
> 
>  *      Returns: BOOLEAN - TRUE if packet should be dropped otherwise FALSE
> 
> but returns SUCCESS (defined as 0) and ERROR (defined as -1).
> 
> Also, shouldn't those functions be converted to return 'bool' when the 
> description say so (happy to do it).

Does anyone use the Cisco MIC code anymore? I guess we can't just rip it
out...  It was a proprietary Cisco extension back before WPA.

In any case, the comment should be changed to reflect the current return
values of the function, and SUCCESS and ERROR in decapsulate() should be
changed to 0 and -1 respectively; defining stuff like success/error just
makes things ugly, and 0 and -1 are well-enough-known that there should
be no question what they mean.

Essentially, the code is using 0 and -1 as booleans anyway.  I say get
rid of SUCCESS & ERROR and just use 0 and -1, then change the comment.

dan

> Richard Knutsson
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

