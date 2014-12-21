From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: SRIOV as bridge Re: [PATCH net-next RESEND] net: Do not call
 ndo_dflt_fdb_dump if ndo_fdb_dump is defined.
Date: Sun, 21 Dec 2014 12:46:25 -0800
Message-ID: <549731A1.3090307@cumulusnetworks.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com>    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>    <5489D53E.5010603@cumulusnetworks.com>    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>    <548AD781.5020004@mojatatu.com> <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl> <548AFD41.3010801@mojatatu.com> <548B4AA4.1020804@gmail.com> <548EF05E.6050401@mojatatu.com> <548F80B2.80408@gmail.com> <54902E5E.2070405@mojatatu.com> <54905F67.2090509@gmail.com> <5496D8E2.1090700@mojatatu.com> <54971A93.6050700@cumulusnetworks.com> <54971D2F.1090802@mojatatu.com> <54972140.30704@cumulusnetworks.com> <54972859.7050108@mojatatu.com>
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
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:53374 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbaLUUqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2014 15:46:33 -0500
In-Reply-To: <54972859.7050108@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/14, 12:06 PM, Jamal Hadi Salim wrote:
> On 12/21/14 14:36, Roopa Prabhu wrote:
>> On 12/21/14, 11:19 AM, Jamal Hadi Salim wrote:
>>> On 12/21/14 14:08, Roopa Prabhu wrote:
>
>> 'self' would just mean the driver owns the PF embedded bridge and the
>> kernel bridge driver has no role in this. 'self' will just tell the VF
>> driver to deal with the fdb mac entry. And the VF driver can push the
>> fdb to the PF  (John can confirm if the intel sriov devices really do it
>> this way or some other way).
>>
>
> If the VFs are exposed as netdevs and the master (or Parent which i 
> think the "P" stands for) they point to
> is the PF - then is the PF a bridge abstraction?
yes, could be, but its not today ('PF' is physical function and 'VF' is 
virtual function).
If you introduce a master/slave relationship between the PF and VF (ie 
VF's were assigned PF as the master using 'ip link set dev vf master 
PF), then yes.
> And if the path is via is the PF - i think that seems like "master"
> not self, no?

Today ...when you add fdb...path is not via the PF netdev. It maybe 
internally done that way in PF/VF driver.
so, 'master' does not apply today. But if there were such a relationship 
between PF/VF, yes, 'master' could be used.

PF does not really need to have a master relationship with the VF. Its 
better that way. Infact it should be that way even in the case of 'the 
switch device class model' because that will allow switch ports to be 
added to a linux bridge (and hence make use of the linux bridge (cumulus 
model). 'master' will be the 'linux bridge device' in this case).

Thanks,
Roopa
