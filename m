From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [tcpdump-workers] Current wireless-testing breaks libpcap:
 mr_alen should be set
Date: Wed, 3 Mar 2010 16:54:34 +0100
Message-ID: <20100303155434.GI2961@psychotron.lab.eng.brq.redhat.com>
References: <1267578048.14049.11.camel@mj>
 <A5B3F074CA554D3E95CFD349116E4D5B@FrankWMillerPC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tcpdump-workers@lists.tcpdump.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: "Frank W. Miller" <frankwmiller@frankwmiller.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18225 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753353Ab0CCPyt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 10:54:49 -0500
Content-Disposition: inline
In-Reply-To: <A5B3F074CA554D3E95CFD349116E4D5B@FrankWMillerPC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 03, 2010 at 04:31:07PM CET, frankwmiller@frankwmiller.net wrote:
>
>Would this be preventing pcap_inject() from working say in kernel 2.6.31
>(stock FC12 kernel)?

Nope. The patch went in just recently.

>
>Thanks,
>FM
>
>
>> -----Original Message-----
>> From: tcpdump-workers-owner@lists.tcpdump.org [mailto:tcpdump-workers-
>> owner@lists.tcpdump.org] On Behalf Of Pavel Roskin
>> Sent: Tuesday, March 02, 2010 6:01 PM
>> To: linux-wireless@vger.kernel.org; netdev@vger.kernel.org; tcpdump-
>> workers@lists.tcpdump.org
>> Cc: Jiri Pirko
>> Subject: [tcpdump-workers] Current wireless-testing breaks libpcap:
>> mr_alen should be set
>> 
>> Hello!
>> 
>> The current wireless-testing appears to have some non-wireless bits from
>> the upcoming Linux 2.6.34.  As a result, libpcap and all capture
>> programs that use it are broken.
>> 
>> This patch to libpcap helps:
>> 
>> --- a/pcap-linux.c
>> +++ b/pcap-linux.c
>> @@ -1563,6 +1563,7 @@ live_open_new(pcap_t *handle, const char
>>  			memset(&mr, 0, sizeof(mr));
>>  			mr.mr_ifindex = handle->md.ifindex;
>>  			mr.mr_type    = PACKET_MR_PROMISC;
>> +			mr.mr_alen    = 6;
>>  			if (setsockopt(sock_fd, SOL_PACKET,
>>  				PACKET_ADD_MEMBERSHIP, &mr, sizeof(mr)) ==
>-1)
>>  			{
>> 
>> libpcap git doesn't have the fix yet.
>> 
>> The breakage must be coming from the commit 914c8ad2 by Jiri Pirko to
>> net/packet/af_packet.c
>> 
>> I think it's very unhelpful to introduce patches that break significant
>> userspace functionality without giving the affected programs an advance
>> warning.
>> 
>> Also, pulling bleeding edge stuff into wireless-testing before rc1
>> appears to be either a mistake or a bad decision.
>> 
>> Sorry for cross-post, but it's an urgent issue.  Repliers are encouraged
>> to trim the recipient list as necessary.
>> 
>> --
>> Regards,
>> Pavel Roskin
>> -
>> This is the tcpdump-workers list.
>> Visit https://cod.sandelman.ca/ to unsubscribe.
>
