From: Chris Snook <csnook@redhat.com>
Subject: Re: tcp write returns 0?
Date: Thu, 21 Aug 2008 16:31:14 -0400
Message-ID: <48ADD092.7080203@redhat.com>
References: <007901c903c1$044b8780$0ce29680$@com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hua Zhong <hzhong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54110 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752516AbYHUUbW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Aug 2008 16:31:22 -0400
In-Reply-To: <007901c903c1$044b8780$0ce29680$@com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hua Zhong wrote:
> Under what condition would tcp write return 0?
> 
> Especially since a previous poll() indicates the socket is writable. Could
> this only happen for socket in NONBLOCK mode?

The socket could become unwritable for various reasons between poll() 
returning and the send() call.  This shouldn't happen very often, but if 
the system is under memory pressure and needs to page in data between 
those two calls, that race window can get rather large.  You might want 
to increase your TCP buffer sizes, either per-socket with setsockopt, or 
system-wide with sysctl.

-- Chris
