From: Teemu Koponen <tkoponen@iki.fi>
Subject: New address announcements in RTMGRP_IPV4_IFADDR netlink group
Date: Mon, 6 Jun 2005 11:59:38 -0700
Message-ID: <aa027950f2fc7f2ad640cac4a11fbe93@iki.fi>
Mime-Version: 1.0 (Apple Message framework v622)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Netlink developers and gurus,

While fine-tuning the handover speed for a certain L3 mobility daemon 
under Linux 2.6.11.10, I stumbled into the following behavior which 
intuitively does not follow the semantics of the RTMGRP_IPV4_IFADDR 
group:

0) A userspace daemon process is running and listening to the broadcast 
group.

1) Address is inserted to an interface (ip addr add ... at shell).

2) The daemon receives a NEWADDR message, just as is should, but the 
daemon is unable to bind to the address *immediately* (actually in the 
function that processes the netlink message). The result is "cannot 
assign an address" from the bind call. However, if I do insert a single 
nanosleep, even with an arbitrary low sleep value, before the bind 
call, the bind then succeeds.

So, what is the semantics of NEWADDR? Should the address be bindable 
right after receiving the message? Or is there a race-condition between 
userspace and kernel that the inserted sleep helps to overcome by 
letting the kernel to run again before the bind call?

TIA,
Teemu

--
