From: Michal Ostrowski <mostrows@watson.ibm.com>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: 25 Jun 2003 09:42:24 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1056548544.1944.1488.camel@brick.watson.ibm.com>
References: <20030625072602.529AF2C0B9@lists.samba.org>
	 <1056547262.1945.1436.camel@brick.watson.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, Paul MacKerras <paulus@samba.org>,
   netdev@oss.sgi.com, fcusack@samba.org,
   "David F. Skoll" <dfs@roaringpenguin.com>,
   James Carlson <carlson@workingcode.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <1056547262.1945.1436.camel@brick.watson.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Perhaps instead of using a special queue that keeps packets ordered, we
add a tag to each skb as it comes off the card and let higher level
protocols use this to re-order things themselves?  (And add some option
for AF_PACKET sockets to optionally enforce this ordering in presenting
packets to apps, or not.)

This may require modifying all drivers, but it does provide for an
explicit mechanism that can be made mandatory for drivers, avoids
special casing, avoids dumping work onto a single CPU and leaves it up
to the higher-level code to figure out ordering, if it wants to.

-- 
Michal Ostrowski <mostrows@watson.ibm.com>
