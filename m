From: Kenan Kalajdzic <kenan@unix.ba>
Subject: Re: [PATCH] socket: Merge getsockname and getpeername into a single
	function
Date: Tue, 9 Mar 2010 16:30:19 +0100
Message-ID: <e0929ea61003090730p23aae935q1f34030df8cc527e@mail.gmail.com>
References: <20100304032612.GB9016@home.unix.ba>
	 <20100308.122413.158901144.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:37471 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752154Ab0CIPaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 10:30:21 -0500
Received: by bwz1 with SMTP id 1so3994846bwz.21
        for <netdev@vger.kernel.org>; Tue, 09 Mar 2010 07:30:19 -0800 (PST)
In-Reply-To: <20100308.122413.158901144.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 8, 2010 at 9:24 PM, David Miller <davem@davemloft.net> wrote:
>
> Since you still have to conditionalize things like the security
> calls, this doesn't look any cleaner to me than what we have
> there already.

You are absolutely right about this - the condition around security
calls ruins the whole refactoring attempt.  It could easily go away if
we were ready to make minor changes to the security code.  It is
because getting the local socket info and getting the peer socket info
are essentially the same type of operation.  Therefore, both
security_socket_getsockname() and security_socket_getpeername()
eventually evaluate to a call to socket_has_perm() with
SOCKET__GETATTR.  The question remains whether it is worth breaking
the cleanness of the security hooks code to get rid of the condition
in 'our' two functions?

-- 
Kenan
