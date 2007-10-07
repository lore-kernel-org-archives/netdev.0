From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET] IPv6 oops bisected
Date: Sun, 07 Oct 2007 10:56:07 -0400
Message-ID: <4708F387.1060602@garzik.org>
References: <4708D677.1030601@garzik.org> <4708E016.9020300@garzik.org> <4708E3CF.4000401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, den@openvz.org,
	David Miller <davem@davemloft.net>
To: "Denis V. Lunev" <dlunev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37484 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752734AbXJGO4P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2007 10:56:15 -0400
In-Reply-To: <4708E3CF.4000401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denis V. Lunev wrote:
> Jeff Garzik wrote:
>> Jeff Garzik wrote:
>>> The commit
>>>
>>> commit 5f5dace1ce001b24fb8286e09ffd3c4d2b547e09
>>> Author: Denis V. Lunev <den@openvz.org>
>>> Date:   Thu Sep 27 12:41:26 2007 -0700
>>>
>>>     [NET]: Various dst_ifdown routines to catch refcounting bugs
>>>
>>> causes a 100% reproducible oops in net-2.6.24.git, in ip6_route_add().
>>>
>>> Platform: x86-64 Fedora 7
>>>
>>> Config and lspci attached.
>> And indeed, reverting this commit with 'patch -R' makes things work again.
>>
>>     Jeff
> 
> Can you me command to execute to reproduce the problem? and oops if
> possible.

The command is Fedora 7 initscripts...

(typing in by hand)

/etc/sysconfig/network-scripts/network-functions-ipv6: line 246: 1760 Killed
	LC_ALL=C /sbin/ip $options


NULL pointer dereference at 0x000003f8

backtrace:
:ipv6:ip6_route_add+0x1b1/0x543
rtnetlink_rcv_msg
inet6_rtm_newroute
netlink_run_queue
rtnetlink_rcv
netlink_data_ready
netlink_sendskb
netlink_sendmsg
sock_send_msg
mntput_no_expire
autoremove_wake_function
find_lock_page
zone_statistics
get_page_from_freelist
__alloc_pages
move_addr_to_kernel
verify_iovec
sys_sendmsg
