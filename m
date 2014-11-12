From: Jianhua Xie <jianhua.xie@freescale.com>
Subject: Re: [PATCH v1 net-next 1/2] bonding: Expand speed type bits of the
 AD Port Key
Date: Wed, 12 Nov 2014 17:53:41 +0800
Message-ID: <54632E25.3000205@freescale.com>
References: <1415603801-21285-1-git-send-email-Jianhua.Xie@freescale.com>
 <1415603801-21285-2-git-send-email-Jianhua.Xie@freescale.com>
 <20141111.135305.1647707440180670390.davem@davemloft.net>
 <19882.1415735238@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <vfalico@gmail.com>, <andy@greyhouse.net>
To: Jay Vosburgh <jay.vosburgh@canonical.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0115.outbound.protection.outlook.com ([157.56.110.115]:5409
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752016AbaKLJxb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2014 04:53:31 -0500
In-Reply-To: <19882.1415735238@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks you two for the valuable comments.

If my understanding is right,  it is encouraged to use a counter
rather than a bitmask for the speed field, right?

if yes, how many bits are better to use for current speed and
future speed (like 100Gbps/400Gbps and etc.)?  I am not sure
that 5 bits are enough (2**5=3D32) or not. And I am clear to keep
"the duplex bit in the key " in my mind.

if not, what's your recommendation please?

Thanks & Best Regards,
Jianhua

=E5=9C=A8 2014=E5=B9=B411=E6=9C=8812=E6=97=A5 03:47, Jay Vosburgh =E5=86=
=99=E9=81=93:
> David Miller <davem@davemloft.net> wrote:
>
>> From: Xie Jianhua <Jianhua.Xie@freescale.com>
>> Date: Mon, 10 Nov 2014 15:16:40 +0800
>>
>>> From: Jianhua Xie <Jianhua.Xie@freescale.com>
>>>
>>> Port Key was determined as 16 bits according to the link speed,
>>> duplex and user key (which is yet not supported), in which key
>>> speed was 5 bits for 1Mbps/10Mbps/100Mbps/1Gbps/10Gbps as below:
>>> --------------------------------------------------------------
>>> Port key :|	User key	| Speed		|	Duplex|
>>> --------------------------------------------------------------
>>> 16			6		1		0
>>> This patch is expanding speed type from 5 bits to 9 bits for other
>>> speed 2.5Gbps/20Gbps/40Gbps/56Gbps and shrinking user key from 10
>>> bits to 6 bits.  New Port Key looks like below:
>>> --------------------------------------------------------------
>>> Port key :|	User key	| Speed		|	Duplex|
>>> --------------------------------------------------------------
>>> 16			10		1		0
>>>
>> Do we determine the layout of this value all ourselves?
> 	Yes, we do.  The precise format of the port key is not defined
> by the standard; IEEE 802.1AX 5.3.5, "Capability identification":
>
> "A given Key value is meaningful only in the context of the System th=
at
> allocates it; there is no global significance to Key values."
>
> 	and
>
> "When a System assigns an operational Key value to a set of ports, it
> signifies that, in the absence of other constraints, the current
> operational state of the set of ports allows any subset of that set o=
f
> ports (including the entire set) to be aggregated together from the
> perspective of the System making the assignment."
>
> 	So, basically, it's a magic cookie that indicates that all ports
> on a particular system with the same key value are suitable to be
> aggregated together.
>
>> If not, then is it exported to anything user-visible that we
>> might be breaking?
> 	The key values are not user-visible, and the "user" settable
> portion of the key has never been implemented.
>
>> If it is private, it makes no sense to use a bitmask for the speed.
>> We should instead change the field to be some numerically increasing
>> value.
>>
>> Otherwise we'll run out of bits again and keep having to adjust the
>> field layout more often than we really need to.
> 	Agreed.
>
> 	Also note that there are some internal dependencies within
> bonding on the format; in particular the duplex bit in the key is use=
d
> to determine if a port is LACP-capable, and that functionality needs =
to
> be preserved.
>
> 	-J
>
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
