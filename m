From: Bruce Cole <bacole@gmail.com>
Subject: Re: Realtek r8168 slow outbound transfer - potential fix/workaround
Date: Mon, 13 Aug 2007 11:53:02 -0700
Message-ID: <46C0A88E.7050802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bacole@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.236]:53509 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759361AbXHMS4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 14:56:34 -0400
Received: by qb-out-0506.google.com with SMTP id e11so2241539qbe
        for <netdev@vger.kernel.org>; Mon, 13 Aug 2007 11:56:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Gundersen <gundy@iinet.net.au> :
 > Now, on to my workaround. Putting a spin style wait like the following
 > in front of the line above seemed to solve the problem for me:
 >
 >
 > if (RTL_R8(TxPoll) & NPQ) {
 >      for (i = 20; i > 0; i--) {
 >       if (!(RTL_R8(TxPoll) & NPQ))
 >        break;
 >       udelay(25);
 >     }
 > }
 >
 > ...
 >
 > RTL_W8(TxPoll, NPQ);

What's the status of this fix?  It (or something more refined) seems 
necessary
to correct the current performance problems with this driver.  Some
background:

I just got a motherboard (gigabyte ga-p35-ds3p) which has built-in ethernet
via the realtek rtl8111b chip.  I've been experiencing serious performance
problems when it comes to transmitting files across the network using samba.
By serious I mean throughput is probably 200X slower than it should be.  
This
is the same problem reported by several others.  Some references:

"[Samba] Miserable read performance":
http://lists.samba.org/archive/samba/2007-July/133553.html
"[Samba] RE: Samba running slow"
http://lists.samba.org/archive/samba/2007-January/128846.html
"Re: Realtek RTL8111B serious performance issues"
http://www.mail-archive.com/netdev@vger.kernel.org/msg42860.html

I started with the stock 2.6.22.1 driver, then I tried the
20070628-2.6.22-rc6-r8169-test.patch on top of it, which made no difference.
Then I tried David Gundersen's spin-wait patch and performance was fixed!

Oddly enough, I don't see this performance problem when I test transmit
performance using ttcp, or even when I transfer files with scp.  It 
seems the
extra application layer latency of something like samba is necessary to
reproduce the problem.

I can troubleshoot in more detail if that would help get a proper fix
developed.

