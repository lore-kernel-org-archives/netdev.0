From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] socket: increase default maximum listen queue length
Date: Sun, 20 Mar 2011 13:14:14 +0100
Message-ID: <20110320121414.GC3038@nuttenaction>
References: <1300585811-21566-1-git-send-email-hagen@jauu.net>
 <1300609817.2831.56.camel@edumazet-laptop>
 <20110320113921.GA3038@nuttenaction>
 <1300622144.2831.287.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:43247 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752096Ab1CTMOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 08:14:16 -0400
Content-Disposition: inline
In-Reply-To: <1300622144.2831.287.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet | 2011-03-20 12:55:44 [+0100]:

>I am not sure you understood what I said.
>
>Even if you change kernel limits, many applications still use low
>limits : listen(fd, 8)

Right, but there is a discrepance between system administrators and server
authors: the later group will probably notice that listen(fd, 8) is not
adequate (e.g. someone send a bug report). System administrators on the other
hand have no obvious indicator that some goes wrong in the system. Most of
then would not even notice that the backlog is overflowing. 

>I remember some other OS (was it HPUX or Solaris...) had a minimum
>limit : Even if application said 8, an admin could impose a 256 value
>for example.

Not the baddest idea! It is nice that a server author can adjust that value.
But between you and me: the system administrator may have more information
about the network behavior (how many incoming connections/minute, RTT, memory
characteristic, ...). The system administrator should be in the ability to
increase the value, currently he is stucked up if the server author missed
that. E.g.

http://www.dovecot.org/list/dovecot-cvs/2009-September/014567.html

I will spin a patch for that.

Hagen
