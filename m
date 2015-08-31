From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] net: Remove VRF change to udp_sendmsg
Date: Mon, 31 Aug 2015 10:22:03 -0700
Message-ID: <CALx6S36YTzCRDQUArzDv5sXHc6wgKxFnxNAauAGj74R_nYQabA@mail.gmail.com>
References: <1441038580-44164-1-git-send-email-dsa@cumulusnetworks.com>
	<CALx6S379ZrcKdapJ0yRwzyW-ACY=45DcJnUNJ6mRZPjJAie1VA@mail.gmail.com>
	<55E4895D.2060202@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:33520 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbbHaRWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 13:22:04 -0400
Received: by iods203 with SMTP id s203so166084831iod.0
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 10:22:03 -0700 (PDT)
In-Reply-To: <55E4895D.2060202@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 31, 2015 at 10:05 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 8/31/15 11:02 AM, Tom Herbert wrote:
>>
>> On Mon, Aug 31, 2015 at 9:29 AM, David Ahern <dsa@cumulusnetworks.com>
>> wrote:
>>>
>>> Remove the VRF change in udp_sendmsg to set the source address. The VRF
>>> driver already has access to the packet on the TX path via the dst. It
>>> can be used to update the source address in the header.
>>>
>>
>> I don't understand this. The previous code was about selecting a
>> source address for packets being sourced ed on a socket, but this new
>> patch seems to essentially be doing SNAT in the VRF transmit path
>> which  seems like a fundamentally different behavior. Is this really
>> your intention?
>>
>
> The original code and this new code are only controlling FIB lookups which
> in turn set the source address. Functionally both versions do the same
> thing.
>
It's a major departure from current convention. The source address of
the packet should be set before doing ip_send_skb. In UDP unconnected
case ip_route_output_flow calls inet_select_addr. AKAIK there is no
provision for not setting the source address and relying on the output
device to do this in its transmit routine. I still think it would be
better to call into the VRF device from inet_select_addr using an ndo
function.

Tom

 > David
>
