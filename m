From: Ben Greear <greearb@candelatech.com>
Subject: SO_BINDTODEVICE mismatch with man page & comments.
Date: Tue, 04 Sep 2007 15:45:14 -0700
Message-ID: <46DDDFFA.6090705@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:57637 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753424AbXIDWpT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2007 18:45:19 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to the comment in the net/core/sock.c code (in 2.6.20), I should be able to pass a zero
optlen to the setsockopt method for SO_BINDTODEVICE:

                 case SO_BINDTODEVICE:
                 {
                         char devname[IFNAMSIZ];

                         /* Sorry... */
                         if (!capable(CAP_NET_RAW)) {
                                 ret = -EPERM;
                                 break;
                         }

                         /* Bind this socket to a particular device like "eth0",
                          * as specified in the passed interface name. If the
                          * name is "" or the option length is zero the socket
                          * is not bound.
                          */

However, earlier in that method it returns -EINVAL if optlen is < sizeof(int).

The man page has comments similar to that in the code above.

Also, even when I get the un-bind call working with code similar to:

int z = 0;
setsockopt(s, SOL_SOCKET, SO_BINDTODEVICE, &z, sizeof(z));

The app I'm working on (Xorp) does not appear to work.  Perhaps because
the kernel does not clean up the cached route when you un-bind
as it does in the (re)bind logic?

                                 /* Remove any cached route for this socket. */
                                 sk_dst_reset(sk);


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

