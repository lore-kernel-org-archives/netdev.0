From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH] lro: IP fragment checking
Date: Tue, 02 Dec 2008 10:36:22 -0500
Message-ID: <493555F6.2030900@myri.com>
References: <4933A74F.3050809@de.ibm.com>	<493423D7.5030203@myri.com>	 <20081201.131810.158631503.davem@davemloft.net> <49345CCA.1030209@myri.com>		 <1228169379.3073.13.camel@achroite> <49347B0B.8030705@myri.com>	 <1228177130.3073.23.camel@achroite> <49354970.10804@myri.com> <1228231128.3075.9.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ossthema@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tklein@de.ibm.com, raisch@de.ibm.com, jb.billaud@gmail.com,
	hering2@de.ibm.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1794 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750799AbYLBPga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 10:36:30 -0500
In-Reply-To: <1228231128.3075.9.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> On Tue, 2008-12-02 at 09:42 -0500, Andrew Gallatin wrote:
>> Ben Hutchings wrote:
>>> On Mon, 2008-12-01 at 19:02 -0500, Andrew Gallatin wrote:
>>>> Ben Hutchings wrote:
> [...]
>>>>> If your hardware/firmware wrongly claims to be able to verify the
>>>>> TCP/UDP checksum for an IP fragment, it seems to me you should deal with
>>>>> that in your driver or fix the firmware.
>>>> We do partial checksums.
>>> So you should check for IP fragmentation in your get_frag_header() along
>>> with all the other checks you've got to do.
>> Indeed, and that is the patch I intend to submit if the fragment
>> check in inet_lro is rejected.  I still think the check belongs
>> in the inet lro code though, and I'm worried it is being rejected
>> for the wrong reasons..
> 
> There's a wide variety of capabilities of different hardware:
> 
> 1. No checksum offload. Probably not worth using LRO.
> 2. Full-checksum generation. Driver passes packets to inet_lro;
> get_frag_header() or get_skb_header() parses packets to check that they
> are TCP/IPv4 and to validate the checksum. inet_lro does further checks.
> 3. L4 packet parsing and checksum validation. Driver passes TCP/IPv4
> packets to inet_lro. inet_lro does further checks.
> 4. Hardware/firmware LRO. inet_lro not needed.
> 
> You seem to be proposing that a check that is only needed in case (2)
> should also be applied in case (3).  Maybe it would make more sense to
> define a generic implementation of get_frag_header() for full-checksum
> devices, if that's possible?

Or maybe a generic lro_check_header() that can be called from
everybody's get_frag_header()/get_skb_header().  I guess what
bothers me is the division of checks between the get_*_header()
routine and lro_tcp_ip_checks() and the inevitable code
duplication in the get_*_header routines.

I still don't understand why an unneeded check for fragmentation
in case (3) is any more objectionable than the existing tcp
flags checks in lro_tcp_ip_check(), many of which are surely
not needed in case (3) either.

Drew
