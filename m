From: Ben Pfaff <blp@cs.stanford.edu>
Subject: Re: question about nla_nest_cancel
Date: Thu, 27 Jan 2011 09:52:53 -0800
Message-ID: <87pqrikzd6.fsf@benpfaff.org>
References: <Pine.LNX.4.64.1101271804530.13796@pc-004.diku.dk>
Reply-To: Ben Pfaff <blp@cs.stanford.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outmail148108.authsmtp.net ([62.13.148.108]:65528 "EHLO
	outmail148108.authsmtp.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751313Ab1A0SMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 13:12:47 -0500
In-Reply-To: <Pine.LNX.4.64.1101271804530.13796@pc-004.diku.dk> (Julia
	Lawall's message of "Thu, 27 Jan 2011 18:08:34 +0100 (CET)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julia Lawall <julia@diku.dk> writes:

> I find numerous occurrences of code like the following, in which nest ends 
> up with the value NULL and then nla_nest_cancel is called with nest as the 
> second argument.  But nla_nest_cancel just calls nlmsg_trim with the same 
> second argument, and nlmsg_trim does nothing if its second argument is 
> NULL.  Is there any reason to keep these calls?

I think that you are missing that NLA_PUT() contains an internal
"goto nla_put_failure;".  If that branch is taken, then
nla_nest_cancel() trims off the nested attribute.  So just
removing the call to nla_nest_cancel() would change behavior in
that case.
-- 
Ben Pfaff 
http://benpfaff.org
