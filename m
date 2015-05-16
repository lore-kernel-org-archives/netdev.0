From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RFC][PATCH] Remove refcounting from unix domain sockets
Date: Sat, 16 May 2015 16:34:30 -0700
Message-ID: <CALCETrUsEpaLjRzgnwQkz_cXM9gjnvuBz5mzrpk=WLR8VNrTmw@mail.gmail.com>
References: <87a8x4o4dy.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:33030 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbbEPXew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 19:34:52 -0400
Received: by lagr1 with SMTP id r1so89790422lag.0
        for <netdev@vger.kernel.org>; Sat, 16 May 2015 16:34:51 -0700 (PDT)
In-Reply-To: <87a8x4o4dy.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 16, 2015 at 9:48 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> While thinking about things it occurred to me that by fixing what is
> arguably in a bug in the unix domain socket implementation I can
> remove the performance penality for credential passing.
>
> That bug is the fact that the cmsg returned on a unix domain socket
> is different depending on who calls recvmsg.  Passing file descriptor
> should not changes how it operates (oops).

I'm having some trouble following what's going on with icred and
ocred.  That being said, I think that you're changing the semantics of
socketpair() followed by unshare(), and I wouldn't be that surprised
if something relies on the current behavior.

>
> There is a second bug this also fixes, pids are now translated as they
> traverse netlink sockets.

Can you describe the bug more clearly?

--Andy
