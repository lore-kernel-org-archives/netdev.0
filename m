From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: BQL-related tg3 transmit timeout on 5720 / Dell R720
Date: Thu, 30 May 2013 07:34:50 -0700
Message-ID: <51A7638A.5030108@broadcom.com>
References: <CAL1RGDW=SC3E9VvQXki0Gajj0xBqwHjBWM95k00J6zn1tF1mgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Roland Dreier" <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4042 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932785Ab3E3Oi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 May 2013 10:38:59 -0400
In-Reply-To: <CAL1RGDW=SC3E9VvQXki0Gajj0xBqwHjBWM95k00J6zn1tF1mgg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 5/30/2013 2:05 AM, Roland Dreier wrote:
> On Wed, May 22, 2013 at 3:02 PM, Roland Dreier <roland@kernel.org> wrote:
>> I'll try to find a kernel where tg3 works on this system so I can bisect.
>
> So I finally was able to successfully bisect our problem with tg3
> transmit timeouts with recent kernels.  Recall this was on on _some_
> of our Dell R720 systems with 4X tg3 ethernet with devices like:
>
>      tg3 0000:02:00.0: eth0: Tigon3 [partno(BCM95720) rev 5720000] (PCI
> Express) MAC address 90:b1:1c:3f:46:b8
>      tg3 0000:02:00.0: eth0: attached PHY is 5720C (10/100/1000Base-T
> Ethernet) (WireSpeed[1], EEE[1])
>
> The bisection came down to
>
>      commit 298376d3e8f00147548c426959ce79efc47b669a
>      Author: Tom Herbert <therbert@google.com>
>      Date:   Mon Nov 28 08:33:30 2011
>
>          tg3: Support for byte queue limits
>
>          Changes to tg3 to use byte queue limits.
>
[...]

> and each send completes in turn.
>
> For now I can work around the issue by hacking BQL out of tg3 in our
> kernel, but I guess it would be good to understand this tg3-specific
> issue of sends not completing and handle that in the tg3 driver.
>

Thanks for the bisect and detailed analysis. I will investigate this 
further.

> I have a system that reproduces this very reliably, so let me know if
> there is any further logging or other info that would help understand
> this further.
>

Is the 5720 a NIC or a LOM? If it's a NIC would it be possible to try it 
on a different system to see if the behaviour depends on the system at all?

> Thanks,
>    Roland
>
