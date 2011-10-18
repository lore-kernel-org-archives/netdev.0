From: Jim Sansing <jjsansing@verizon.net>
Subject: Comment on nf_queue NF_STOLEN patch
Date: Tue, 18 Oct 2011 15:08:29 -0400
Message-ID: <4E9DCEAD.7070603@verizon.net>
References: <4E988B1E.5000606@itcare.pl>
 <CAEuXFEy89F_=J_PJMSbQ1fDcOEkkpz2vucq3LcToi7rTcZHcDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms173003pub.verizon.net ([206.46.173.3]:64959 "EHLO
	vms173003pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405Ab1JRUvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 16:51:06 -0400
Received: from [192.168.1.5] ([unknown] [108.15.85.191])
 by vms173003.mailsrvcs.net
 (Sun Java(tm) System Messaging Server 7u2-7.02 32bit (built Apr 16 2009))
 with ESMTPA id <0LTA002DE1SPRHX0@vms173003.mailsrvcs.net> for
 netdev@vger.kernel.org; Tue, 18 Oct 2011 14:50:50 -0500 (CDT)
In-reply-to: <CAEuXFEy89F_=J_PJMSbQ1fDcOEkkpz2vucq3LcToi7rTcZHcDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have been working on a kernel module that registers with netfilter,
and I noticed that a patch was added to nf_queue that changed the
handling of return code NF_FILTER from 'do nothing' to 'free the skb'. 
I'm not sure which kernel version this went in, but the date of the
patch is Feb, 19, 2010.

Everything I have read about netfilter states that it is up to the
netfilter hook to free the skb if NF_STOLEN is returned.  The
implications of this patch from a hook programming perspective are:

1) If the skb is used after the return from the hook, it must be cloned.
2) The original skb must not be freed.

I suggest that a comment be added to include/linux/netfilter.h that says
explicitly the skb will be freed if NF_STOLEN is returned.


Later . . .   Jim
