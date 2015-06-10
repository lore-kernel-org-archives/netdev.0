From: Josh Hunt <johunt@akamai.com>
Subject: Re: [PATCH v3] ipv6: Fix protocol resubmission
Date: Wed, 10 Jun 2015 16:57:25 -0500
Message-ID: <5578B2C5.7080202@akamai.com>
References: <1433779259-14328-1-git-send-email-johunt@akamai.com>	<20150608.121601.1357405469784892473.davem@davemloft.net> <m2mw08kx7b.wl@gmail.com> <55783A1B.3070207@akamai.com> <557854BB.1090605@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Hajime Tazaki <thehajime@gmail.com>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@trash.net, netdev@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com, tom@herbertland.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:51854 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932587AbbFJV51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 17:57:27 -0400
In-Reply-To: <557854BB.1090605@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/10/2015 10:16 AM, YOSHIFUJI Hideaki wrote:
> Hi,
>
> Josh Hunt wrote:
>> On 06/09/2015 11:24 PM, Hajime Tazaki wrote:
>>>
>>> Hello Josh, Dave,
>>>
>>> my mobile ipv6 test on libos failed with this commit.
>>>
>>> This commit makes a destination option header handling (i.e.,
>>> ipprot->handler == ipv6_destopt_rcv) failed since
>>> ipv6_destopt_rcv() seems to return a positive value to
>>> indicate to goto resubmission label.
>>>
>>> I will look for more detail.
>>>
>>> -- Hajime
>>
>> Hajime
>>
>> Thanks for the report. I mentioned in an earlier post this might be a problem.
>>
>> Dave, what if we restore the old behavior, but add a new label to handle the case where the decapsulating protocol returns the nexthdr value? Allowing for migration over to this method over time. I've pasted in a patch doing so below.
>
> I think it is insufficient because IPv6 stack already uses
> positive value, 0 and negative values.
>
>>
>> The other solution I guess is to change how the udp handler works, but I was hoping to keep it behaving the same as v4.
>
> xfrm returns different value for IPv4 and IPv6, for example,
> so udp can do in the same way.  And we can use the fact that
> the size of next header field is 8-bit.
>

Dave

Can you please revert this change?

commit 0243508edd317ff1fa63b495643a7c192fbfcd92
Author: Josh Hunt <johunt@akamai.com>
Date:   Mon Jun 8 12:00:59 2015 -0400

     ipv6: Fix protocol resubmission

Let me know if you need a patch to do this and I will submit something.

I will fix the original issue in the UDP code in another patch.

Josh
