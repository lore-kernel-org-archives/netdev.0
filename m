From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is
 incorrect for sockets in accept(3)
Date: Tue, 20 Oct 2015 08:30:27 -0700
Message-ID: <1445355027.22974.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151019095938.72ea48e6@xeon-e3>
	 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>
	 <562594E1.8040403@oracle.com>
	 <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <56261092.7080003@oracle.com>
	 <1445347173.22974.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <56264596.90104@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34544 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079AbbJTPa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 11:30:29 -0400
Received: by padhk11 with SMTP id hk11so24660637pad.1
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 08:30:29 -0700 (PDT)
In-Reply-To: <56264596.90104@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-10-20 at 14:45 +0100, Alan Burlison wrote:

> And I still haven't seen any reasoning behind the Linux close() and 
> poll() behaviour on sockets that are in the listen state.

Same answer.

A close() does _not_ wakeup an accept() or a poll() (this is exactly the
same problem), or any blocking system call using the same 'file'

This is the choice Linus Torvalds and Al Viro did years ago.

It is set in stone, unless someone comes up with a very nice patch set,
that does not break existing applications.

close() man page states :

NOTES
      It  is  probably unwise to close file descriptors while they may be in
      use by system calls in other threads in the  same  process.   Since  a
      file  descriptor may be reused, there are some obscure race conditions
      that may cause unintended side effects.

You are in this grey zone.
