From: Dan Smith <danms@us.ibm.com>
Subject: Re: Question about netns & AF_UNIX
Date: Thu, 27 May 2010 11:08:56 -0700
Message-ID: <87d3whb4jr.fsf@caffeine.danplanet.com>
References: <AANLkTikBuXfzS-UIL7bDMvfpL5lx9gMqHTpGg-jrm5Zv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: =?utf-8?Q?Mart=C3=ADn?= Ferrari <martin.ferrari@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:41462 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932573Ab0E0SI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 14:08:59 -0400
In-Reply-To: <AANLkTikBuXfzS-UIL7bDMvfpL5lx9gMqHTpGg-jrm5Zv@mail.gmail.com>
 (=?utf-8?Q?=22Mart=C3=ADn?= Ferrari"'s message of "Thu\, 27 May 2010
 16\:38\:29 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MF> I seem to recall being able to use AF_UNIX sockets across network name
MF> spaces, but I cannot reproduce that with a current kernel. Probably my
MF> test was fubar (I've lost the script).

If you are in different network namespaces, the binding of UNIX
sockets is also kept separate.  Even though the filesystem is shared,
this seems to make the most sense to me.  Named pipes on the
filesystem would still be shared, by the way.

MF> I also wonder if filedescriptor passing thru ancilliary messages will
MF> work (that is, with unix sockets that I've created before the netns
MF> change).

I think that will work, as will binding a socket and then doing a
setns().

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
