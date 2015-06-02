From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [RFC net-next 3/3] mpls: new ipmpls device for encapsulating
 IP packets as mpls
Date: Tue, 2 Jun 2015 22:06:24 +0100
Message-ID: <556E1AD0.1010304@brocade.com>
References: <1433177175-16775-1-git-send-email-rshearma@brocade.com> <1433177175-16775-4-git-send-email-rshearma@brocade.com> <556DD688.2020308@cumulusnetworks.com> <556DDAEF.9080209@brocade.com> <556DFC91.1090708@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Thomas Graf <tgraf@suug.ch>,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	"Vivek Venkatraman" <vivek@cumulusnetworks.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:46403 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751158AbbFBVHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 17:07:34 -0400
In-Reply-To: <556DFC91.1090708@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/15 19:57, roopa wrote:
> On 6/2/15, 9:33 AM, Robert Shearman wrote:
>> On 02/06/15 17:15, roopa wrote:
>>> On 6/1/15, 9:46 AM, Robert Shearman wrote:
>>>> Allow creating an mpls device for the purposes of encapsulating IP
>>>> packets with:
>>>>
>>>>    ip link add type ipmpls
>>>>
>>>> This device defines its per-nexthop encapsulation data as a stack of
>>>> labels, in the same format as for RTA_NEWST. It uses the encap data
>>>> which will have been stored in the IP route to encapsulate the packet
>>>> with that stack of labels, with the last label corresponding to a
>>>> local label that defines how the packet will be sent out. The device
>>>> sends packets over loopback to the local MPLS forwarding logic which
>>>> performs all of the work.
>>>>
>>>>
>>> Maybe a silly question, but when you loop the packet back, what does the
>>> local MPLS forwarding logic
>>> lookup with ? It probably assumes there is a mpls route with that label
>>> and nexthop.
>>> Will this need any internal labels (thinking same label stack different
>>> tunnel device etc) ?
>>
>> Yes, it requires that local/internal labels have been allocated and
>> label routes installed in the label table for them.
> This is our only concern.
>>
>> It is entirely possible to put the outgoing interface into the encap
>> data to avoid having to allocate extra labels, but I did it this way
>> in order to support PIC Core for MPLS-VPN routes.
>
> hmm..., is a netdevice must in this case.., can you please elaborate on
> this ?.

Yes, the ipmpls device would still be used to perform the encapsulation, 
transitioning from the IP forwarding path to the MPLS forwarding path.

Thanks,
Rob
