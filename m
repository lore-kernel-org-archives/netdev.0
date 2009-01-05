From: Joerg Pommnitz <pommnitz@yahoo.com>
Subject: Hello! Making some rattling noise! RE: Bug? Undocumented interaction between IPv6 IPsec and iptables MARK target
Date: Mon, 5 Jan 2009 06:21:02 -0800 (PST)
Message-ID: <53703.46131.qm@web51405.mail.re2.yahoo.com>
Reply-To: pommnitz@yahoo.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web51405.mail.re2.yahoo.com ([206.190.38.184]:36374 "HELO
	web51405.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752780AbZAEOVF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2009 09:21:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I still have not read anybody commenting on the observed behavior. I still consider this a bug. Am I right?

-- 
Regards
       Joerg


--- Joerg Pommnitz <pommnitz@yahoo.com> schrieb am Fr, 19.12.2008:

> Von: Joerg Pommnitz <pommnitz@yahoo.com>
> Betreff: Bug? Undocumented interaction between IPv6 IPsec and iptables MARK target
> An: netdev@vger.kernel.org
> Datum: Freitag, 19. Dezember 2008, 10:26
> Hello all,
> the following script demonstrates a behaviour of IPv6 IPsec
> that I would
> consider to be a bug (tested with 2.6.23 and 2.6.27-9 from
> Ubuntu Intrepid):
> 
> ======================================================
> #!/bin/bash
> ip addr add dev eth0 2001:1b10:1001:ff00::0001/64 setkey -c
> << __EOF__ 
> spdflush;
> flush;
> 
> add 2001:1b10:1001:ff00::0001 2001:1b10:1001:ff00::0002 esp
> 0x00000005 -m tunnel -E rijndael-cbc
> 0xefe8e2e8a43e518afa8e9474ad9a4abf986807fc178bd192;
> spdadd 2001:1b10:1001:ff00::0001 2001:1b10:1001:ff00::/64
> any -P out ipsec
> esp/tunnel/2001:1b10:1001:ff00::0001-2001:1b10:1001:ff00::0002/require;
> __EOF__
> 
> ip6tables -t mangle -A OUTPUT -d 2001:1b10:1001:ff00::2 -j
> MARK --set-mark=1
> 
> ping6 2001:1b10:1001:ff00::2
> ======================================================
> 
> This script adds an IPsec policy that should encrypt
> packets sent to 
> 2001:1b10:1001:ff00::2. This works fine as long as no MARK
> value is
> assigned to the packets. When one applies a MARK value
> different from 0,
> the policy doesn't match any more. In IPv4 the IPsec
> policies are 
> unaffected by the MARK.
> 
> So: Is this intended on the kernel side? If yes, how can I
> write manual
> policies that either ignore the MARK value or contain a
> matching value?
> 
> Thanks in advance and kind regards
>   Joerg


      
