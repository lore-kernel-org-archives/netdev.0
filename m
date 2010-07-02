From: Christophe Ngo Van Duc <cngovanduc@gmail.com>
Subject: Re: bnx2/5709: Strange interrupts spread
Date: Fri, 2 Jul 2010 19:12:29 -0300
Message-ID: <AANLkTimTcqANb3HQuC1W6VHWTh0ixO1lXAmVrmP6OZy2@mail.gmail.com>
References: <AANLkTiniNNPV9ztxXHtX4np7PIZabkm0I4v5O29chf8i@mail.gmail.com>
	<1278104311.11828.12.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57965 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752700Ab0GBWMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 18:12:31 -0400
Received: by wwb24 with SMTP id 24so650698wwb.1
        for <netdev@vger.kernel.org>; Fri, 02 Jul 2010 15:12:30 -0700 (PDT)
In-Reply-To: <1278104311.11828.12.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Well that's the strange thing: it is IP traffic. The only difference
with eth0 and eth1 is that eth2 and eth3 belongs to a bridge (br0).

Best Regards,
Christophe.

On 7/2/10, Michael Chan <mchan@broadcom.com> wrote:
>
> On Fri, 2010-07-02 at 13:33 -0700, Christophe Ngo Van Duc wrote:
>> On eth2 (external card) all interrupts goes to CPU0
>>
>>
>>            CPU0       CPU1       CPU2       CPU3       CPU4       CPU5
>>   CPU6       CPU7
>>   80:   46973077          0          0          0          0          0
>>       0          0   PCI-MSI-edge      eth2-0
>>   81:          0          0          0          0          0          0
>>       0          0   PCI-MSI-edge      eth2-1
>>   82:          0          0          0          0          0          0
>>       0          0   PCI-MSI-edge      eth2-2
>>   83:          0          0          0          0          0          0
>>       0          0   PCI-MSI-edge      eth2-3
>>   84:          0          0          0          0          0          0
>>       0          0   PCI-MSI-edge      eth2-4
>>   85:          0          0          0          0          0          0
>>       0          0   PCI-MSI-edge      eth2-5
>>   86:          0          0       2445          0         37          0
>>    8463         13   PCI-MSI-edge      eth2-6
>>   87:          0          0          0          0          0          0
>>       0          0   PCI-MSI-edge      eth2-7
>
> Reformatted your output
>
>> If I understand correctly the RSS hash is used to dispatch the packets
>> into the different queues running on the different CPU.
>
> It looks like most interrupts go to eth2-0, a few go to eth2-6.  The rx
> ring for eth2-0 is for non-IP packets.  The RSS hash will hash IP
> packets and place them on eth2-1 to eth2-7.  eth2-0 also handles tx
> interrupts for TX ring 0.  TX traffic is hashed by the stack.
>
> What kind of traffic is passing through eth2?
>
> Thanks.
>
>
>

-- 
Sent from my mobile device
