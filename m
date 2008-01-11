From: slavon@bigtelecom.ru
Subject: Simple question about LARTC theory
Date: Fri, 11 Jan 2008 20:17:29 +0300
Message-ID: <20080111201729.uev61lnpc4oo0cs8@mail.bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=windows-1251;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:37900 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757464AbYAKRRc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 12:17:32 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id ACBABA6C0FB
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 20:17:30 +0300 (MSK)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id x-jf98Gr3F7c for <netdev@vger.kernel.org>;
	Fri, 11 Jan 2008 20:17:29 +0300 (MSK)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all.
Sorry for offtopic. I subscribe only on netdev@vger.kernel.org... try  
send to lartc@vger.kernel.org and get "Undelivered Mail Returned to  
Sender". May i do small offtop? This maillist have many people that  
known lartc "in code" and i hope its help for my idea. Thanks.

Simple Question

Legend
[] - qdisc
() - class
** - filter

[htb 1:0 root] *match X FLOWID 3:5*
(1:2 htb)(2:3 htb)(3:5 htb)[sfq 5]
(1:6 htb)(6:7 htb)(7:8 htb)[sfq 8]

packet go
IN -> [htb 1:0] -> (class 1:2 - GREEN) -> (class 2:3 GREEN) -> (class
3:5 - GREEN) -> [sfq 5] -> OUT

then i create

[prio 3 bound 10:0] *match X flowid 10:2*
+(10:1 htb) -- [sfq 101]
+(10:2 htb) -- [sfq 102]
+(10:3 htb) -- [sfq 103]

HOW to add filter to [sfq 5] and [sfq 8]  that then packet go out from
it its go to [prio 3 bound 10:0] and do filter from it?

flowid work if it see begin and end of links... i need like GOTO... if
i add to [prio 3 bound 10:0] PARRENT ID - flowid found path, but i
need that [prio 3 bound 10:0] must have more 1 parrent...

i look to "link" but if i understand - its work for only for hashtables
i look to classid but its go to class 10:X, not to [prio 3 bound 10:0]
and not process filter...

Or i not understand theory?

That i need? I need 3 groups in tc
1-st group get all traffic and do HTB shape (defence from ICMP and UDP shtorm)
a) icmp rate 100mbs cell 500mbs
b) udp rate 100mbs cell 500mbs
c) other rate 300mbs cell 500mbs
all prio = 0 to do normal cellrate

2-nd group do prio ( icmp and udp must be first becouse its not have  
check for transmit)
icmp = 1
udp = 2
other = 3

3-th group do speed limit by IP (shape it) ( this part is ready )

i wont that all exits on group 1 go to group 2 filters and all exits  
on group 2 go to group 3 exists...

Thanks. Slavon


----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.

