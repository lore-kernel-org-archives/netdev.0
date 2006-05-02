From: Just Marc <marc@corky.net>
Subject: Disabling "TCP Treason uncloaked"
Date: Tue, 02 May 2006 17:19:29 +0100
Message-ID: <44578691.4020402@corky.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from corky.net ([212.150.53.130]:10708 "EHLO zebday.corky.net")
	by vger.kernel.org with ESMTP id S964884AbWEBPU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 May 2006 11:20:29 -0400
Received: from zebday.corky.net (zebday [127.0.0.1])
	by zebday.corky.net (Postfix) with ESMTP id B853F8F79B
	for <netdev@vger.kernel.org>; Tue,  2 May 2006 18:20:28 +0300 (IDT)
Received: from [127.0.0.1] (zebday [127.0.0.1])
	by zebday.corky.net (Postfix) with ESMTP id 3E4CE8F7B4
	for <netdev@vger.kernel.org>; Tue,  2 May 2006 18:20:28 +0300 (IDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi everyone,

Looking at mailing list archives there has been much talk of this print 
in the past, given the fact that this check/print is surrounded by an 
#ifdef TCP_DEBUG

#ifdef TCP_DEBUG
       if (net_ratelimit()) {
           struct inet_sock *inet = inet_sk(sk);
           printk(KERN_DEBUG "TCP: Treason uncloaked! Peer 
%u.%u.%u.%u:%u/%u shrinks window %u:%u. Repaired.\n",
                  NIPQUAD(inet->daddr), htons(inet->dport),
                  inet->num, tp->snd_una, tp->snd_nxt);
       }
#endif

I thought that maybe it's time to either set TCP_DEBUG to 0 or 
alternatively allow an admin to toggle the printing of this message 
off/on?  On a few busy web servers running usually latest versions of 
2.6 I have this message displaying hundreds (if not more) times a day, 
completely clogging the kernel log and making it harder to see if there 
are more interesting messages being printed.   TCP_DEBUG is being used 
in one more place that may also not require it anymore and or have it 
always enabled.

So, is it time to disable this print altogether? Is it time to allow an 
admin to toggle printing of this thing off?

Thanks for your time
