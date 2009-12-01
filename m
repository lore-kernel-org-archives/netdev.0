From: "Chris Friesen" <cfriesen@nortel.com>
Subject: seeing strange values for tcp sk_rmem_alloc
Date: Tue, 01 Dec 2009 10:16:42 -0600
Message-ID: <4B15416A.2060202@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Linux kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:43350 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754160AbZLAQS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 11:18:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm hoping someone might be able to explain some odd behaviour that I'm
seeing.

Some of our developers wanted to be able to see how much of their rx
socket buffer space was in use, so I added the following to sock_ioctl()


		case SIOCGSKRMEMALLOC:
		{
			int tmp;
			err = -EINVAL;
			if(!sock->sk)
				break;
			tmp = atomic_read(&sock->sk->sk_rmem_alloc);
			err = copy_to_user(argp, &tmp, sizeof(tmp));
			break;
		}

To validate it, I wrote a testcase that opened a tcp socket, then looped
sending 2k of data at a time to it and calling the above ioctl to check
the sk_rmem_alloc value (without ever reading from the socket).

The results were odd--I've copied them below.  Can anyone explain how I
can send 20K of data but sk_rmem_alloc still only shows 4.8K used, then
it suddenly jumps by a lot on the next packet to something that more
reflects reality, then repeats that pattern again?  Is there some
additional buffering happening somewhere in the TCP stack?

Thanks,

Chris

used: 2424
used: 4848
used: 4848
used: 4848
used: 4848
used: 4848
used: 4848
used: 4848
used: 4848
used: 4848
used: 23696
used: 23696
used: 23696
used: 23696
used: 23696
used: 23696
used: 23696
used: 23696
used: 23696
used: 42544
used: 42544
used: 42544
used: 42544
used: 42544
used: 42544
used: 42544
used: 42544
used: 42544
used: 61392
used: 61392
used: 61392
used: 61392
used: 61392
used: 61392
used: 61392
used: 61392
used: 61392
used: 80240
used: 80240
used: 80240
used: 80240
used: 80240
used: 80240
used: 80240
used: 80240
used: 80240
used: 80240
used: 80240
used: 80240
used: 80240
used: 80240
used: 80240
used: 80240
used: 80240
used: 80240
used: 80240
used: 80240
used: 80240


