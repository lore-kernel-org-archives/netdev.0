From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH v2 1/1] xen/netback: correctly calculate required
 slots of skb.
Date: Thu, 11 Jul 2013 21:35:40 +0800
Message-ID: <51DEB4AC.8090409@oracle.com>
References: <1373447711-31303-1-git-send-email-annie.li@oracle.com> <1373530274.5453.148.camel@hastur.hellion.org.uk> <51DE6DFD.9080007@oracle.com> <1373536078.5453.159.camel@hastur.hellion.org.uk> <4A59CC63-9B57-49FA-A2FD-6903C86E110E@oracle.com> <3038108B-5529-452A-A488-4E616F7C1B8E@oracle.com> <1373541144.5453.165.camel@hastur.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"wei.liu2@citrix.com" <wei.liu2@citrix.com>,
	"msw@amazon.com" <msw@amazon.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38650 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932291Ab3GKNfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 09:35:53 -0400
In-Reply-To: <1373541144.5453.165.camel@hastur.hellion.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-7-11 19:12, Ian Campbell wrote:
>>>>> The code here only
>>>>> increase count for the first time. I thought to initialize the
>>>>> count in
>>>>> xen_netbk_count_skb_slots with 1 to avoid this. But thinking of
>>>>> the
>>>>> extreme case when the header size is zero(not sure whether this
>>>>> case
>>>>> could be true), I increase the count here to keep safe in case
>>>>> header
>>>>> size is zero.
>>>> netfront requires that the first slot always contains some data,
>>>> gop_frag_copy will BUG if that's not the case.
>>>>
>>
>> In gop_frag_copy, we can not go into the while if the size is 0. Which
>> BUG_ON do you mean here?
> in gop_frag_copy:
> 		if (start_new_rx_buffer(npo->copy_off, bytes, *head)) {
> 			/*
> 			 * Netfront requires there to be some data in the head
> 			 * buffer.
> 			 */
> 			BUG_ON(*head);
>
But If there is SKB with zero header size and zero offset, the code will 
not run into the while loop in gop_frag_copy and this if condition. 
BUG_ON will not happen in such situation.

Thanks
Annie
