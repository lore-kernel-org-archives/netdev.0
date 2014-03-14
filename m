From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next 2/2] bonding: use the correct ether type for alb
Date: Fri, 14 Mar 2014 12:27:19 -0700
Message-ID: <25318.1394825239@death.nxdomain>
References: <1394710918-29540-3-git-send-email-vfalico@redhat.com> <20140314.142935.1237930025090619830.davem@davemloft.net> <20140314184251.GA30498@redhat.com> <20140314.151233.2074289397216762525.davem@davemloft.net>
Cc: vfalico@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:37913 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754591AbaCNT13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 15:27:29 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 14 Mar 2014 13:27:29 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 64D413E4003F
	for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 13:27:25 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2EJQsdk8585618
	for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 20:26:54 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s2EJUwNr011829
	for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 13:30:59 -0600
In-reply-to: <20140314.151233.2074289397216762525.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

>From: Veaceslav Falico <vfalico@redhat.com>
>Date: Fri, 14 Mar 2014 19:42:52 +0100
>
>> On Fri, Mar 14, 2014 at 02:29:35PM -0400, David Miller wrote:
>>>From: Veaceslav Falico <vfalico@redhat.com>
>>>Date: Thu, 13 Mar 2014 12:41:58 +0100
>>>
>>>> @@ -1005,7 +1005,7 @@ static void alb_send_lp_vid(struct slave *slave,
>>>> u8 mac_addr[],
>>>>  	memset(&pkt, 0, size);
>>>>  	ether_addr_copy(pkt.mac_dst, mac_addr);
>>>>  	ether_addr_copy(pkt.mac_src, mac_addr);
>>>> -	pkt.type = cpu_to_be16(ETH_P_LOOP);
>>>> +	pkt.type = cpu_to_be16(ETH_P_LOOPBACK);
>>>
>>>Had this really never worked properly at all?
>> 
>> Yep, but only in cases where the hw/sw didn't filter out broken
>> packets
>> *before* arp processing, as far as I can tell.
>
>Hmmm... what I meant was, was anyone able to receive these packets?
>I think the answer is no.

	My recollection is that the intended target of the packets was
the switch the system was connected to, and their only function was to
update the MAC table of the switch (via the source MAC of the frame).

	How well they really work today is debateable (meaning that I'm
not even sure they're necessary, at least not as a regular
transmission), but I recall discussing this with somebody at Intel years
ago and these were evidently necessary at one time.

	The ETH_P_LOOP Linux ended up with was (again, as I recall) a
simplification of some kind of active monitoring system on the Intel ANS
product that the alb/tlb code was derived from, wherein some agent would
receive and reply to the frames.  The ANS product used ethertype 0x886d
for its probes, however.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
