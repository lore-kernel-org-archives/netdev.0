From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 3/9] net: Remove e_nobufs label from
 ip_route_input_slow
Date: Thu, 24 Sep 2015 10:53:23 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBA1549@AcuExch.aculab.com>
References: <1442962523-3974-1-git-send-email-dsa@cumulusnetworks.com>
	<1442962523-3974-4-git-send-email-dsa@cumulusnetworks.com>
 <877fnhc24l.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "'Eric W. Biederman'" <ebiederm@xmission.com>,
	David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.193]:54598 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753294AbbIXKy1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 06:54:27 -0400
In-Reply-To: <877fnhc24l.fsf@x220.int.ebiederm.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman
> Sent: 23 September 2015 03:15
> David Ahern <dsa@cumulusnetworks.com> writes:
> 
> > e_nobufs has 1 user. Move setting err to -ENOBUFS for the 1 user and
> > use the goto out label instead of e_nobufs. Stepping stone patch; next
> > one moves rth code into a helper function.
> 
> Ick you are pessimizing the code.
> 
> You will almost certainly have better code generation if you hoist
> the assignment of "err = -ENOBUFS" above the rt_dst_alloc then you
> don't need to do anything in your error path except "goto out;"

Unlikely to make a difference.
The compiler is very likely to set 'err' before the conditional
branch anyway. It will use an extra register to make it all work.

	David
