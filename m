From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: Linux 2.6.35/TIPC 2.0 ABI breaking changes
Date: Mon, 18 Oct 2010 19:11:37 -0400
Message-ID: <4CBCD429.8090306@windriver.com>
References: <20101018150422.GV8781@llucax.com.ar>	<20101018184628.GX8781@llucax.com.ar>	<AANLkTimKbOreV4Fuyw3TbCrk9aa5yBZQSuRbo3Vdx=Q1@mail.gmail.com> <20101018.151708.193712688.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: luca@llucax.com.ar, jon.maloy@ericsson.com,
	tipc-discussion@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:47681 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756117Ab0JRXMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 19:12:16 -0400
In-Reply-To: <20101018.151708.193712688.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-10-18 06:17 PM, David Miller wrote:
> From: Paul Gortmaker<paul.gortmaker@windriver.com>
> Date: Mon, 18 Oct 2010 16:42:33 -0400
> 
>> If you have access to the user space code in question, you can just
>> switch behaviour semantics based on the results of a uname call, knowing
>> that this change was included in versions since approx last Feb.  There
>> is also /proc/version which can be parsed manually if you prefer.
> 
> Requiring userspace to check kernel versioning information in order
> to user an exported userspace API correctly is _ALWAYS_ _WRONG_.
> 
> You cannot and must not make backwards incompatible changes to
> userspace interfaces.

What I think has happened here (and I'll double check this
tomorrow, since it is before I started assisting with tipc)
is that a backwards incompatible change *did* inadvertently
creep in via these two (related) commits:

--------------
commit d88dca79d3852a3623f606f781e013d61486828a
Author: Neil Horman <nhorman@tuxdriver.com>
Date:   Mon Mar 8 12:20:58 2010 -0800

    tipc: fix endianness on tipc subscriber messages
--------------

and

---------------
commit c6537d6742985da1fbf12ae26cde6a096fd35b5c
Author: Jon Paul Maloy <jon.maloy@ericsson.com>
Date:   Tue Apr 6 11:40:52 2010 +0000

    TIPC: Updated topology subscription protocol according to latest spec
---------------

Based on Leandro's info, I think it comes down to userspace
not knowing exactly where to find these bits anymore:

#define TIPC_SUB_SERVICE       0x00    /* Filter for service availability    */
#define TIPC_SUB_PORTS         0x01    /* Filter for port availability  */
#define TIPC_SUB_CANCEL         0x04    /* Cancel a subscription         */

...because it doesn't know if there is the old auto endian
 swap thing being done or not being done.

Assuming it is possible to do so in some non-kludgy way,
it sounds like we want to be looking into an in-kernel change
that ensures the older user space binaries get their
functionality restored then?

Thanks,
Paul.
