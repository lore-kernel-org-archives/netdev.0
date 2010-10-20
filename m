From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: Linux 2.6.35/TIPC 2.0 ABI breaking changes
Date: Wed, 20 Oct 2010 14:37:02 -0400
Message-ID: <0434463FDA60A94FA978ACA44617682DEE8466821E@EUSAACMS0702.eamcs.ericsson.se>
References: <4CBCD429.8090306@windriver.com>
	<20101018234547.GA5703@hmsreliant.think-freely.org>
	<20101019021657.GZ8781@llucax.com.ar>
	<20101019.011649.71113115.davem@davemloft.net>
	<20101019110452.GA14410@hmsreliant.think-freely.org>
	<20101019131936.GB8781@llucax.com.ar>
	<20101019201841.GC14410@hmsreliant.think-freely.org>
	<20101020172018.GN8781@llucax.com.ar>
	<0434463FDA60A94FA978ACA44617682DEE84668199@EUSAACMS0702.eamcs.ericsson.se>
	<20101020182411.GO8781@llucax.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>, David Miller <davem@davemloft.net>
To: Leandro Lucarella <luca@llucax.com.ar>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20101020182411.GO8781@llucax.com.ar>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

<...>

> 
> Just to try to understand better how things works, or are supposed to
> work: do the subscription and event messages (and I mean the 
> struct tipc_subscr and tipc_event published in tipc.h) really 
> go over the wire or are only used to communicate the stack to 
> the application inside a node?

Both. And, given TIPC fundamental "location transparency" principle
the sender (or receiver) at user level does not need to know the 
difference.
For a TIPC user, all messages are "local", insofar they stay within
the same cluster.

> 
> I think this is a crucial matter, since it defines if the 
> changes cross kernel/userspace boundaries only or it also 
> crosses the kernel/network boundaries.
> 
> > Remember, permitting both is a superset of the current one 
> (NBO only) 
> > so it is fully backwards compatible. We break absolutly nothing by 
> > permitting this.
> 
> I think if they really go through the wire, it should be in 
> NBO, and if tipc_subscr and tipc_event are used only 
> internally, we can still fix the userspace messages when 
> sending them through the wire.

There are plenty of protocols around not using NBO over the wire.
This is not a must. 

> 
> In any case, I agree that the patches should be reverted and 
> a solution should be planned with more time and consensus.
> 
> Thanks.
> 
> -- 
> Leandro Lucarella (AKA luca)                     http://llucax.com.ar/
> ----------------------------------------------------------------------
> GPG Key: 5F5A8D05 (F8CD F9A7 BF00 5431 4145  104C 949E BFB6 5F5A 8D05)
> ----------------------------------------------------------------------
> The world's best known word is "okay"
> The second most well-known word is "Coca-Cola"
> 
------------------------------------------------------------------------------
Nokia and AT&T present the 2010 Calling All Innovators-North America contest
Create new apps & games for the Nokia N8 for consumers in  U.S. and Canada
$10 million total in prizes - $4M cash, 500 devices, nearly $6M in marketing
Develop with Nokia Qt SDK, Web Runtime, or Java and Publish to Ovi Store 
http://p.sf.net/sfu/nokia-dev2dev
