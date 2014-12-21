From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: SRIOV as bridge Re: [PATCH net-next RESEND] net: Do not call
 ndo_dflt_fdb_dump if ndo_fdb_dump is defined.
Date: Sun, 21 Dec 2014 11:36:32 -0800
Message-ID: <54972140.30704@cumulusnetworks.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com>    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>    <5489D53E.5010603@cumulusnetworks.com>    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>    <548AD781.5020004@mojatatu.com> <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl> <548AFD41.3010801@mojatatu.com> <548B4AA4.1020804@gmail.com> <548EF05E.6050401@mojatatu.com> <548F80B2.80408@gmail.com> <54902E5E.2070405@mojatatu.com> <54905F67.2090509@gmail.com> <5496D8E2.1090700@mojatatu.com> <54971A93.6050700@cumulusnetworks.com> <54971D2F.1090802@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Hubert Sokolowski <h.sokolowski@wit.edu.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:47242 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbaLUTgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2014 14:36:35 -0500
In-Reply-To: <54971D2F.1090802@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/14, 11:19 AM, Jamal Hadi Salim wrote:
> On 12/21/14 14:08, Roopa Prabhu wrote:
>> PF still stays but not as the management interface.
>>
>> Even if 'TheClassThingy' where there, you wouldn't refer to it as the
>> master (ie the PF will not have a netdev master/slave relationship with
>> the VF). 'master' will still be used for the netdev 'upper' device if
>> VF was enslaved to one (which could be a bridge).
>>
>
> Well, there is an embedded switch underneath the VFs (in hardware).
> You cant send pkts from one VF to another without going through this
> switch (or in VEPA mode via it). i.e you dont need a kernel bridge.
understood. And since you don't need the kernel bridge, you don't need 
the kernel netdev master construct here.
>
> So in essence the VF is a bridge port to  this embedded switch (as
> is the PF). So the role of master points downwards from the kernel.
> Master is just not visible at the kernel. 
exactly. So you will not be able to use the kernel 'master' in this case.
> I am not sure what "self"
> would mean in this case.
'self' would just mean the driver owns the PF embedded bridge and the 
kernel bridge driver has no role in this. 'self' will just tell the VF 
driver to deal with the fdb mac entry. And the VF driver can push the 
fdb to the PF  (John can confirm if the intel sriov devices really do it 
this way or some other way).

> This is why i dont think current switchdev approach would work.
Current switchdev code in the kernel supports a driver managing its own 
switch with 'self' calls. ie bypassing the kernel bridge driver. Since 
sriov devices already did it that way...., they will just continue to 
work. They are not broken.
But, yes, for sriov devices to use the switchdev model...may need some work.

Good thing you brought up these points. A BOF to close on these things 
at netdev will be good.

Thanks,
Roopa
