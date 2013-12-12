From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next RFC 0/5] xen-netback: TX grant mapping instead
 of copy
Date: Thu, 12 Dec 2013 22:08:15 +0000
Message-ID: <52AA33CF.6030004@citrix.com>
References: <1383094220-14775-1-git-send-email-zoltan.kiss@citrix.com>		 <1383303035.672.29.camel@kazak.uk.xensource.com>		 <5273FA37.6020903@citrix.com>	 <1383821563.26213.168.camel@kazak.uk.xensource.com>	 <52977F5C.7090703@citrix.com> <1385660592.20209.27.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385660592.20209.27.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28/11/13 17:43, Ian Campbell wrote:
> On Thu, 2013-11-28 at 17:37 +0000, Zoltan Kiss wrote:
> Routing/firewalling domUs is as valid as bridging. There is nothing in
> the slightest bit suboptimal about it.
>
> If this use case regresses with this approach then I'm afraid that
> either needs to be addressed or a different approach considered.
>
>> Anyway, I will try this out, and see if it really copies everything, and
>> get some numbers as well.
>
> Thanks.

Now I managed to try it out. As I expected, Dom0 does copy the mapped 
page. The peak throuhput I could get was 6.6 Gbps, however it could keep 
that only for short periods, I guess when the unmapping was ideally 
batched. The average was 5.53.
On the same machine the same 10 min iperf session, without my patches 
made the peak 5.9 while the average was 5.65. Do you think it is an 
acceptable regression?
I used 3.12 Dom0 and guest kernel, the guest transmitted though a 10Gb 
card to a bare metal box.
I plan to look further if we can avoid somehow this:

https://lkml.org/lkml/2012/7/20/363

So then this scenario can benefit from grant mapping.

Regards,

Zoli
