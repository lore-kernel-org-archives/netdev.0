From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: SRIOV as bridge Re: [PATCH net-next RESEND] net: Do not call
 ndo_dflt_fdb_dump if ndo_fdb_dump is defined.
Date: Sun, 21 Dec 2014 22:13:00 -0500
Message-ID: <54978C3C.4040102@mojatatu.com>
References: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>    <54894850.5000603@cumulusnetworks.com>    <7968540cd0768a770b0c8b29ce41a162.squirrel@poczta.wsisiz.edu.pl>    <5489D53E.5010603@cumulusnetworks.com>    <8d4ec5c1ae73c77866a0a154fb528f23.squirrel@poczta.wsisiz.edu.pl>    <548AD781.5020004@mojatatu.com> <4c22a6c452a73b3b77a9a9c8e7f76bcc.squirrel@poczta.wsisiz.edu.pl> <548AFD41.3010801@mojatatu.com> <548B4AA4.1020804@gmail.com> <548EF05E.6050401@mojatatu.com> <548F80B2.80408@gmail.com> <54902E5E.2070405@mojatatu.com> <54905F67.2090509@gmail.com> <5496D8E2.1090700@mojatatu.com> <54971A93.6050700@cumulusnetworks.com> <54971D2F.1090802@mojatatu.com> <54972140.30704@cumulusnetworks.com> <54972859.7050108@mojatatu.com> <549731A1.3090307@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Hubert Sokolowski <h.sokolowski@wit.edu.pl>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:42121 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbaLVDNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2014 22:13:05 -0500
Received: by mail-ie0-f170.google.com with SMTP id rd18so3714079iec.1
        for <netdev@vger.kernel.org>; Sun, 21 Dec 2014 19:13:03 -0800 (PST)
In-Reply-To: <549731A1.3090307@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/14 15:46, Roopa Prabhu wrote:
> On 12/21/14, 12:06 PM, Jamal Hadi Salim wrote:

> yes, could be, but its not today ('PF' is physical function and 'VF' is
> virtual function).
> If you introduce a master/slave relationship between the PF and VF (ie
> VF's were assigned PF as the master using 'ip link set dev vf master
> PF), then yes.


When someone says "modprobe igb max_vfs=19" then 19 VFs show up. i.e the
driver creates them. And then there is assumed direct relationship
between VF and PF. The PF being the parent. Adding fdbs goes via PF.

>> And if the path is via is the PF - i think that seems like "master"
>> not self, no?
>
> Today ...when you add fdb...path is not via the PF netdev.

For SRIOV it is. Example to add via pf eth10 an
fdb entry to the igb hardware fdb to point to vf1:
ip link set eth10 vf 1 mac aa:bb:cc:dd:ee:ff vlan 10
That last part "vf 1 mac aa:bb:cc:dd:ee:ff vlan 10" is typically
part of an "fdb add semantic" - but we explicitly call out
eth10, the parent. The PF has control of the hardware fdb.

It maybe
> internally done that way in PF/VF driver.
> so, 'master' does not apply today. But if there were such a relationship
> between PF/VF, yes, 'master' could be used.
>

I am refering if were to get rid of using iplink. There has to be 
something pointed to by vf1 that gets called to add the fdb entry in
hardware.

> PF does not really need to have a master relationship with the VF. Its
> better that way. Infact it should be that way even in the case of 'the
> switch device class model' because that will allow switch ports to be
> added to a linux bridge (and hence make use of the linux bridge (cumulus
> model). 'master' will be the 'linux bridge device' in this case).
>

So what do you do if the user sets either one of master/self and it 
doesnt make sense?

cheers,
jamal


> Thanks,
> Roopa
