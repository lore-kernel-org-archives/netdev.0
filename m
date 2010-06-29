From: Ben Greear <greearb@candelatech.com>
Subject: RFC:  Allow 'ip' to run in daemon mode?
Date: Tue, 29 Jun 2010 08:34:41 -0700
Message-ID: <4C2A1291.7000203@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55703 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753912Ab0F2Pen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 11:34:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm considering modifying 'ip' to be able to run in daemon
mode so that I can do lots of IP commands without having to
pay the startup cost of iproute.

The -batch option almost works, but it's hard to programatically
figure out failure codes.

I'm thinking about making these changes:

1)  Move all of the error printing code into common methods (basically,
    wrap printf).  In daemon mode this text can be sent back to the
    calling process, and in normal mode, it will be printed to stdout/stderr
    as it is currently.

2)  Remove all or most calls to 'exit' and instead return error codes
    to the calling logic.

3)  Add ability to listen on a unix socket for commands, basically treat
    them just like batch commands, one command per packet.

4)  Return well formatted error code and text response to calling process
    over the unix socket, maybe something like:

RV: [errno or equiv, zero for success]\n
CMD: [ command string this relates to ]\n
[ Optional free form text ]


Does something like this have any chance of upstream inclusion?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
