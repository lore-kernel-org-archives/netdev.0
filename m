From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] lwt: fix rx checksum setting for lwt devices
 tunneling over ipv6
Date: Tue, 16 Feb 2016 15:40:04 -0500 (EST)
Message-ID: <20160216.154004.1823575040012545784.davem@davemloft.net>
References: <CAEh+42jyFVjM4A5HzJQ94xW+XZOTG5iBEFu2VHKCJU0sRwNgWA@mail.gmail.com>
	<20160216.144759.1984502562641417028.davem@davemloft.net>
	<CAEh+42jbaryH8J4vZYXM0yVQcaXZ23Q59_iHr8QT_2PHRmDGgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, pabeni@redhat.com, netdev@vger.kernel.org,
	pshelar@nicira.com, tgraf@suug.ch
To: jesse@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39820 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838AbcBPUkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 15:40:06 -0500
In-Reply-To: <CAEh+42jbaryH8J4vZYXM0yVQcaXZ23Q59_iHr8QT_2PHRmDGgg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@kernel.org>
Date: Tue, 16 Feb 2016 12:11:57 -0800

> On Tue, Feb 16, 2016 at 11:47 AM, David Miller <davem@davemloft.net> wrote:
>> From: Jesse Gross <jesse@kernel.org>
>> Date: Tue, 16 Feb 2016 10:22:38 -0800
>>
>>> On Thu, Feb 11, 2016 at 2:41 AM, Jiri Benc <jbenc@redhat.com> wrote:
>>> There's a bigger problem here, not really related to lightweight tunnels or OVS.
>>>
>>> The VXLAN RFC says (referring to the UDP checksum and not specific to IPv4/v6):
>>> "It SHOULD be transmitted as zero. When a packet is received with a
>>> UDP checksum of zero, it MUST be accepted for decapsulation."
>>>
>>> We can debate whether this is correct or whether it conflicts with RFC
>>> 2460 but this is what essentially everyone is going to implement. With
>>> the default settings of the flags in IPv6, we are violating both
>>> statements. With the second one in particular, the result is that
>>> Linux will not be able to communicate with any non-Linux VXLAN
>>> endpoint over IPv6 with default settings.
>>
>> I do not see any such conflict here.
>>
>> It's a SHOULD, therefore a recommendation.  Likely they thought this
>> would improve performance, and ironically it has the opposite effect.
>>
>> The text of the VXLAN RFC does not say that the checksum MUST be sent
>> as zero, and it also does not say that receiving a non-zero checksum
>> is violating the RFC.
>>
>> I therefore do not see the interoperability issue.  Maybe some
>> deployed systems will run more slowly or hit a slot path (which is not
>> our problem), but they absolutely should not drop such frames.
> 
> "When a packet is received with a UDP checksum of zero, it MUST be
> accepted for decapsulation."
> 
> This is a requirement and directly in conflict with having
> VXLAN_F_UDP_ZERO_CSUM6_RX set to false as the default.

Oh yes, I'm mixing different parts of the conversation.  We must
accept on RX zero checksum fields even for ipv6 because of the way the
VXLAN RFC is worded, correct.
