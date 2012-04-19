From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: RTM_NEWLINK not received by application when connecting multiple
 devices simultaneously
Date: Thu, 19 Apr 2012 13:44:51 +0200
Message-ID: <CAKfDRXj+mydkzNFC8q2aE_JWHp3ie0cijC-itkm6sHLuZr98Fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:38934 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754921Ab2DSLow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 07:44:52 -0400
Received: by iagz16 with SMTP id z16so11818554iag.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 04:44:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am working on my own network manager and have come across a problem
that I have tried to solve for the last couple of days, but with no
luck. My application works by creating a rtnl_handle, joining the
RTMGRP_LINK group, and then using select to do I/O multiplexing (on
the netlink socket) with a pipe used to control the application. I
have written my own function for receiving the packets, called
rtnl_listen_single, which is basically rtnl_listen without the
while(1) loop. When it receives a RTM_NEWLINK message, the application
calls a handle, which configures the interfaces accordingly (for
example by requesting and setting IP, route, netmask, ...).

The application works as intended when I connect interfaces one by
one. However, if I connect two interfaces "simultaneously", the
RTM_NEWLINK message for one of the interfaces is sometimes not
received. Nothing arrives at the handle. It seems to be random which
RTM_NEWLINK actually arrives. I have only been able to recreate this
problem when connecting two USB 3G modems and automatically dialing
the ISP, but I assume it would happen with other technologies as well.
What puzzles me, is that both RTM_NEWLINK messages are seen by for
example ip monitor. This has led me to conclusion that there is a bug
in my application, and my question is therefore, are there any common
mistakes one can make or things to forget that would cause a message
to get lost or not be received, or does anyone have any tips on where
I can start looking?

In order to figure out this, I have so far tried the following:

- I have checked the return value of different functions and made sure
that they return the correct value. So, in other words, for example
the processing of the nlmsg completes and every message is looked at.
However, I have yet to see a rtnetlink message with NLMSG_MULTI set.

- I have made sure that the buffer size is large enough to buffer a
sufficient number of packets. SO_RCVBUF is set to the default of 32
768.

- The handle is still open and valid, as following messages are
received successfully. For example, if I disconnect another interface,
the RTM_NEWLINK message is received.

- I have also checked that the missing message is not blocked, as the
next event does not cause any unintended packets to be received.

The machine I am working on is running the 3.2.0 kernel, with Debian
6.0.4 and iproute-dev marked 20100519-3.

Thanks in advance for any help!

-Kristian
