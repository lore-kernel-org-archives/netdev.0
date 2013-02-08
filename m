From: Jonathan <jdccdevel@gmail.com>
Subject: SS utility and UDP Sockets
Date: Fri, 08 Feb 2013 11:20:38 -0700
Message-ID: <511541F6.7080202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:47111 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946728Ab3BHSQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 13:16:47 -0500
Received: by mail-pa0-f48.google.com with SMTP id hz10so2246835pad.7
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 10:16:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello:

I apologize in advance if this isn't the right mailing list for this 
question.

I think I've found a bug in the "ss" command from the iproute2 package.

The "ss" command is not listing UDP sockets when given the "-4 -a" 
option combination. Since TCP and UDP sockets can both be IPv4, this is 
somewhat unexpected.

As you can see below, this seems to be a bug in the option parsing, as 
it works as expected when combined with the "-tu" or "-u" options. (I 
expected the output of "ss -4 -a" and "ss -tu -4 -a" to be identical.)

[root@router-20130128 xinetd.d]# ss -4 -a
State       Recv-Q Send-Q                                  Local 
Address:Port                                      Peer Address:Port
LISTEN      0 64 *:time                                                 *:*
LISTEN      0 128 *:ssh                                                  
*:*
ESTAB       0      0 172.30.1.72:ssh 172.30.1.61:43687
ESTAB       0      0 172.30.1.72:ssh 172.30.1.61:43602
[root@router-20130128 xinetd.d]# ss -tu -4 -a
Netid State      Recv-Q Send-Q                                Local 
Address:Port                                    Peer Address:Port
udp   UNCONN     0 0 
*:time                                               *:*
tcp   LISTEN     0 64 
*:time                                               *:*
tcp   LISTEN     0 128 
*:ssh                                                *:*
tcp   ESTAB      0      0 172.30.1.72:ssh 172.30.1.61:43687
tcp   ESTAB      0      0 172.30.1.72:ssh 172.30.1.61:43602
[root@router-20130128 xinetd.d]# ss -4 -u -a
State       Recv-Q Send-Q                                  Local 
Address:Port                                      Peer Address:Port
UNCONN      0 0 *:time                                                 *:*

I'm using the "iproute2 3.6.0-2" package from Arch Linux.

Thanks!

Jonathan
