From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH v1 net-next 1/2] bonding: Expand speed type bits of the AD Port Key
Date: Tue, 11 Nov 2014 11:47:18 -0800
Message-ID: <19882.1415735238@famine>
References: <1415603801-21285-1-git-send-email-Jianhua.Xie@freescale.com> <1415603801-21285-2-git-send-email-Jianhua.Xie@freescale.com> <20141111.135305.1647707440180670390.davem@davemloft.net>
Cc: Jianhua.Xie@freescale.com, netdev@vger.kernel.org,
	vfalico@gmail.com, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:60269 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533AbaKKTr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 14:47:26 -0500
In-reply-to: <20141111.135305.1647707440180670390.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

>From: Xie Jianhua <Jianhua.Xie@freescale.com>
>Date: Mon, 10 Nov 2014 15:16:40 +0800
>
>> From: Jianhua Xie <Jianhua.Xie@freescale.com>
>> 
>> Port Key was determined as 16 bits according to the link speed,
>> duplex and user key (which is yet not supported), in which key
>> speed was 5 bits for 1Mbps/10Mbps/100Mbps/1Gbps/10Gbps as below:
>> --------------------------------------------------------------
>> Port key :|	User key	| Speed		|	Duplex|
>> --------------------------------------------------------------
>> 16			6		1		0
>> This patch is expanding speed type from 5 bits to 9 bits for other
>> speed 2.5Gbps/20Gbps/40Gbps/56Gbps and shrinking user key from 10
>> bits to 6 bits.  New Port Key looks like below:
>> --------------------------------------------------------------
>> Port key :|	User key	| Speed		|	Duplex|
>> --------------------------------------------------------------
>> 16			10		1		0
>> 
>> CC: Jay Vosburgh <j.vosburgh@gmail.com>
>> CC: Veaceslav Falico <vfalico@gmail.com>
>> CC: Andy Gospodarek <andy@greyhouse.net>
>> CC: David S. Miller <davem@davemloft.net>
>> 
>> Signed-off-by: Jianhua Xie <jianhua.xie@freescale.com>
>
>Do we determine the layout of this value all ourselves?

	Yes, we do.  The precise format of the port key is not defined
by the standard; IEEE 802.1AX 5.3.5, "Capability identification":

"A given Key value is meaningful only in the context of the System that
allocates it; there is no global significance to Key values."

	and

"When a System assigns an operational Key value to a set of ports, it
signifies that, in the absence of other constraints, the current
operational state of the set of ports allows any subset of that set of
ports (including the entire set) to be aggregated together from the
perspective of the System making the assignment."

	So, basically, it's a magic cookie that indicates that all ports
on a particular system with the same key value are suitable to be
aggregated together.

>If not, then is it exported to anything user-visible that we
>might be breaking?

	The key values are not user-visible, and the "user" settable
portion of the key has never been implemented.

>If it is private, it makes no sense to use a bitmask for the speed.
>We should instead change the field to be some numerically increasing
>value.
>
>Otherwise we'll run out of bits again and keep having to adjust the
>field layout more often than we really need to.

	Agreed.

	Also note that there are some internal dependencies within
bonding on the format; in particular the duplex bit in the key is used
to determine if a port is LACP-capable, and that functionality needs to
be preserved.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
