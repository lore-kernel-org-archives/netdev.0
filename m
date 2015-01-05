From: Vadim Kochan <vadim4j@gmail.com>
Subject: iproute2: Run over all netns
Date: Mon, 5 Jan 2015 14:23:33 +0200
Message-ID: <20150105122333.GA6646@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:53123 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753215AbbAEMd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 07:33:57 -0500
Received: by mail-lb0-f181.google.com with SMTP id l4so17255041lbv.40
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 04:33:56 -0800 (PST)
Received: from angus-think.wlc.globallogic.com ([195.234.75.250])
        by mx.google.com with ESMTPSA id vl1sm7133295lbb.21.2015.01.05.04.33.55
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jan 2015 04:33:55 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I have some piece of code which allow 'ip cmd'
on each netns, I found it useful for getting some info
from all the netns in one shot, BUT I faced with one issue
which mostly related to the user interface design. The problem
is that it would be good to print netns name only when
user uses "show" command, but not for updating/adding (IMHO),
but its hard to find the good way to implement this.

To run each netns the 'ip -net all CMD ...' construction can be used.

I see the following options for this:

#1 Add additional option ( -N ? ) for show netns label on each executing of CMD:

    # ip -net all -N link

    [test_net]
    1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default 
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

    [home0]
    1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default 
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

    [lan0]
    1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default 
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

    [wan0]
    1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default 
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    2: br0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default 
        link/ether 16:f7:cb:b6:7a:8e brd ff:ff:ff:ff:ff:ff

    [vnet0]
    1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default 
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00


    and w/o:

    # ip -net all link

    1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default 
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

    1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default 
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

    1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default 
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

    1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default 
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    2: br0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default 
        link/ether 16:f7:cb:b6:7a:8e brd ff:ff:ff:ff:ff:ff

    1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default 
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

    the last one is not so useful right ?

#2 Prints netns name by default if "-net all" was specified
(add option to prevent this ?), so it will be printed even on the
add/del/change commands ...

    # ip -net all link add ...

    [home0]
    [lan0]
    [wan0]
    [vnet0]

    but does it really useless to see that it will shows all the netns
    on which cmd has been ran ?

#3 Do a lot of refactoring to explicitly show netns name for all
"show" commands ...

#4 The tricky option is to look for the all kinds of "show", "ls",
"list" commands in the args and print the netns name when 'all' netns was
specified.

I 'd like to hear your feedbacks, even if someone will say that ALL this
sucks:).

Regards,
