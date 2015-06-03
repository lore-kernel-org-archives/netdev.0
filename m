From: Vivek Venkatraman <vivek@cumulusnetworks.com>
Subject: Re: [RFC net-next 3/3] mpls: new ipmpls device for encapsulating IP
 packets as mpls
Date: Wed, 3 Jun 2015 11:43:18 -0700
Message-ID: <CAMs_D18-g5Ux3bQaPhX8S0+q0c6T7YBjFXUrYXQ6-s_t_YKc0w@mail.gmail.com>
References: <1433177175-16775-1-git-send-email-rshearma@brocade.com>
	<1433177175-16775-4-git-send-email-rshearma@brocade.com>
	<556DD688.2020308@cumulusnetworks.com>
	<556DDAEF.9080209@brocade.com>
	<556DFC91.1090708@cumulusnetworks.com>
	<556E1AD0.1010304@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: roopa <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Thomas Graf <tgraf@suug.ch>,
	Dinesh Dutt <ddutt@cumulusnetworks.com>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:35629 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755618AbbFCSnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 14:43:19 -0400
Received: by igbyr2 with SMTP id yr2so120417808igb.0
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 11:43:19 -0700 (PDT)
In-Reply-To: <556E1AD0.1010304@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 2, 2015 at 2:06 PM, Robert Shearman <rshearma@brocade.com> wrote:
> On 02/06/15 19:57, roopa wrote:
>>
>> On 6/2/15, 9:33 AM, Robert Shearman wrote:
>>>
>>> On 02/06/15 17:15, roopa wrote:
>>>>
>>>> On 6/1/15, 9:46 AM, Robert Shearman wrote:
>>>>>
>>>>> Allow creating an mpls device for the purposes of encapsulating IP
>>>>> packets with:
>>>>>
>>>>>    ip link add type ipmpls
>>>>>
>>>>> This device defines its per-nexthop encapsulation data as a stack of
>>>>> labels, in the same format as for RTA_NEWST. It uses the encap data
>>>>> which will have been stored in the IP route to encapsulate the packet
>>>>> with that stack of labels, with the last label corresponding to a
>>>>> local label that defines how the packet will be sent out. The device
>>>>> sends packets over loopback to the local MPLS forwarding logic which
>>>>> performs all of the work.
>>>>>
>>>>>
>>>> Maybe a silly question, but when you loop the packet back, what does the
>>>> local MPLS forwarding logic
>>>> lookup with ? It probably assumes there is a mpls route with that label
>>>> and nexthop.
>>>> Will this need any internal labels (thinking same label stack different
>>>> tunnel device etc) ?
>>>
>>>
>>> Yes, it requires that local/internal labels have been allocated and
>>> label routes installed in the label table for them.
>>
>> This is our only concern.
>>>
>>>
>>> It is entirely possible to put the outgoing interface into the encap
>>> data to avoid having to allocate extra labels, but I did it this way
>>> in order to support PIC Core for MPLS-VPN routes.
>>
>>
>> hmm..., is a netdevice must in this case.., can you please elaborate on
>> this ?.
>
>
> Yes, the ipmpls device would still be used to perform the encapsulation,
> transitioning from the IP forwarding path to the MPLS forwarding path.
>

Transitioning from IP forwarding to MPLS forwarding as you have here
will certainly facilitate PIC core when another path exists to the
edge. But it cannot deal with PIC edge, right? Additionally, this
approach would mean that the user's (iproute2) view would be rather
strange - while the actual forwarding requires labels L1 and L2
(bottom) to be pushed when forwarding to a destination, it would look
as if labels L3 and L2 are pushed and then L3 is swapped with L1.

A different way to achieve PIC (core and edge) without transitioning
from IP forwarding to MPLS forwarding may be to introduce the concept
of an alternate nexthop with something (e.g., link status) determining
which nexthop is used.

> Thanks,
> Rob
