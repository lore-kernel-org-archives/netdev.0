From: Vivek Venkatraman <vivek@cumulusnetworks.com>
Subject: Re: [RFC net-next 3/3] mpls: new ipmpls device for encapsulating IP
 packets as mpls
Date: Thu, 4 Jun 2015 14:38:41 -0700
Message-ID: <CAMs_D1-jT1xNS14w9m17nJwWE8QwqvEnvoXEjwJPgxc5UgJWaw@mail.gmail.com>
References: <1433177175-16775-1-git-send-email-rshearma@brocade.com>
	<1433177175-16775-4-git-send-email-rshearma@brocade.com>
	<556DD688.2020308@cumulusnetworks.com>
	<556DDAEF.9080209@brocade.com>
	<556DFC91.1090708@cumulusnetworks.com>
	<556E1AD0.1010304@brocade.com>
	<CAMs_D18-g5Ux3bQaPhX8S0+q0c6T7YBjFXUrYXQ6-s_t_YKc0w@mail.gmail.com>
	<55709D23.2000008@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: roopa <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Thomas Graf <tgraf@suug.ch>,
	Dinesh Dutt <ddutt@cumulusnetworks.com>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:35728 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbbFDVim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 17:38:42 -0400
Received: by wiga1 with SMTP id a1so1773229wig.0
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 14:38:41 -0700 (PDT)
In-Reply-To: <55709D23.2000008@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 4, 2015 at 11:46 AM, Robert Shearman <rshearma@brocade.com> wrote:
> On 03/06/15 19:43, Vivek Venkatraman wrote:
>>
>> On Tue, Jun 2, 2015 at 2:06 PM, Robert Shearman <rshearma@brocade.com>
>> wrote:
>>>
>>> On 02/06/15 19:57, roopa wrote:
>>>>
>>>>
>>>> On 6/2/15, 9:33 AM, Robert Shearman wrote:
>>>>>
>>>>>
>>>>> On 02/06/15 17:15, roopa wrote:
>>>>>>
>>>>>>
>>>>>> On 6/1/15, 9:46 AM, Robert Shearman wrote:
>>>>>>>
>>>>>>>
>>>>>>> Allow creating an mpls device for the purposes of encapsulating IP
>>>>>>> packets with:
>>>>>>>
>>>>>>>     ip link add type ipmpls
>>>>>>>
>>>>>>> This device defines its per-nexthop encapsulation data as a stack of
>>>>>>> labels, in the same format as for RTA_NEWST. It uses the encap data
>>>>>>> which will have been stored in the IP route to encapsulate the packet
>>>>>>> with that stack of labels, with the last label corresponding to a
>>>>>>> local label that defines how the packet will be sent out. The device
>>>>>>> sends packets over loopback to the local MPLS forwarding logic which
>>>>>>> performs all of the work.
>>>>>>>
>>>>>>>
>>>>>> Maybe a silly question, but when you loop the packet back, what does
>>>>>> the
>>>>>> local MPLS forwarding logic
>>>>>> lookup with ? It probably assumes there is a mpls route with that
>>>>>> label
>>>>>> and nexthop.
>>>>>> Will this need any internal labels (thinking same label stack
>>>>>> different
>>>>>> tunnel device etc) ?
>>>>>
>>>>>
>>>>>
>>>>> Yes, it requires that local/internal labels have been allocated and
>>>>> label routes installed in the label table for them.
>>>>
>>>>
>>>> This is our only concern.
>>>>>
>>>>>
>>>>>
>>>>> It is entirely possible to put the outgoing interface into the encap
>>>>> data to avoid having to allocate extra labels, but I did it this way
>>>>> in order to support PIC Core for MPLS-VPN routes.
>>>>
>>>>
>>>>
>>>> hmm..., is a netdevice must in this case.., can you please elaborate on
>>>> this ?.
>>>
>>>
>>>
>>> Yes, the ipmpls device would still be used to perform the encapsulation,
>>> transitioning from the IP forwarding path to the MPLS forwarding path.
>>>
>>
>> Transitioning from IP forwarding to MPLS forwarding as you have here
>> will certainly facilitate PIC core when another path exists to the
>> edge. But it cannot deal with PIC edge, right?
>
>
> Right, it won't allow to PIC edge to work as is, but it could be a step
> towards implementing PIC edge.
>
>> Additionally, this
>> approach would mean that the user's (iproute2) view would be rather
>> strange - while the actual forwarding requires labels L1 and L2
>> (bottom) to be pushed when forwarding to a destination, it would look
>> as if labels L3 and L2 are pushed and then L3 is swapped with L1.
>
>
> Right, but a level of indirection is required somehow. The natural level of
> indirection is the L3 nexthop, but that is more complicated and I don't know
> if that sort of change would be welcome.
>
>> A different way to achieve PIC (core and edge) without transitioning
>> from IP forwarding to MPLS forwarding may be to introduce the concept
>> of an alternate nexthop with something (e.g., link status) determining
>> which nexthop is used.
>
>
> I'm not sure I understand. Could you elaborate on this?

Indirection on the L3 nexthop is what I meant. I agree that it would
be more complicated. The thought was to model it like ECMP, so there
would be a set of nexthops (2 for main and alternate), but it would be
a protection group instead of a shared group.

>
> Thanks,
> Rob
