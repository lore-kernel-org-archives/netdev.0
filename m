From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next 00/10] NCSI Support
Date: Thu, 7 Jul 2016 23:05:16 +1000
Message-ID: <20160707130516.GA24646@gwshan>
References: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <CAJ3xEMjEup1VUeCr3g2Ry78HvprfnC6wjGd=MWjnMOLWdLyKdQ@mail.gmail.com>
 <20160705174433.GA73415@ast-mbp.thefacebook.com>
 <CAJ3xEMgRqa_=MmPyRmOU=hUAF3o6N5A0dToa6hSwSut6QvosKw@mail.gmail.com>
 <1467883056.27157.28.camel@kernel.crashing.org>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Gavin Shan <gwshan@linux.vnet.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, joel@jms.id.au,
	weixue@trustnetic.com, Yuval Itkin <yuvali@mellanox.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:60543 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750952AbcGGNFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 09:05:37 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u67D06Yv077857
	for <netdev@vger.kernel.org>; Thu, 7 Jul 2016 09:05:37 -0400
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2415xn2pdt-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 09:05:36 -0400
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Thu, 7 Jul 2016 18:35:30 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id AA91BE0060
	for <netdev@vger.kernel.org>; Thu,  7 Jul 2016 18:39:24 +0530 (IST)
Received: from d28av08.in.ibm.com (d28av08.in.ibm.com [9.184.220.148])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u67D5RCv60752056
	for <netdev@vger.kernel.org>; Thu, 7 Jul 2016 18:35:27 +0530
Received: from d28av08.in.ibm.com (localhost [127.0.0.1])
	by d28av08.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u67D5Lh6018097
	for <netdev@vger.kernel.org>; Thu, 7 Jul 2016 18:35:26 +0530
Content-Disposition: inline
In-Reply-To: <1467883056.27157.28.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 07, 2016 at 07:17:36PM +1000, Benjamin Herrenschmidt wrote:
>On Thu, 2016-07-07 at 12:12 +0300, Or Gerlitz wrote:
>> On Tue, Jul 5, 2016 at 8:44 PM, Alexei Starovoitov
>> <alexei.starovoitov@gmail.com> wrote:
>> > On Mon, Jul 04, 2016 at 01:03:06AM +0300, Or Gerlitz wrote:
>> 
>> > Or, since cx4 has ncsi as well, could you do a thorough review of this
>> > to make sure that it fits mellanox nics as well?
>> 
>> Hi Alexei, all
>> 
>> Yuval from our team who deals with host management did review on the
>> series, SB his feedback.
>> 

Thanks for the review and the comments.

>> 1. The initialization uses a single unicast MAC address which hints it
>> assumes that the management traffic is IPv4 only. The infrastructure
>> does not seem to be ready for IPv6 based management traffic.
>
>You mean the transfer of the MAC address from the BMC to the NIC for
>filtering incoming traffic ?
>

I think it's about global multicast filter which is used for IPv6 to
probe next neighbhour or hop. I will add it according to the retrieved
channel's capability in next revision.

>> 2. The code enables AEN messages (all the 3 messages defined by the
>> standard are enabled). AEN support mandates readiness on the BMC side
>> (running the reviewed code) and mandates support on the NIC. Not every
>> NIC can create AEN messages therefore I would recommend that the code
>> will only enable AENs which are declared as supported. To query
>> support for AEN messages, the BMC shall interpret the response for
>> "Get Capabilities" command and based on the returned response it can
>> detect which AEN message is supported by the NIC and may be enabled.
>
>Ok.
>

Yes, It makes sense. I will enable AEN messages according to channel's
capability in next revision.

>> 3. When stating support for NC-SI it is important to indicate which
>> exact version of NC-SI is supported (or required). From my observation
>> this code is based on NC-SI 1.0.0 as it does not use any of the
>> features which were introduced in the later versions.
>
>Probably correct, 1.0.1 I think is the only one that was available when
>we started that work. I found 1.1.0 on the DMTF web site, are you aware
>of anything more recent ?
>
>Gavin, you can get it here:
>
> https://www.dmtf.org/sites/default/files/standards/documents/DSP0222_1.1.0.pdf
>

Yeah, the code was implemented based on 1.0.1 specification as Ben said.
I go through 1.1.0 specification quickly. On page 65, there are more
optional commands added as below. I will define them in ncsi-pkt.h and
I don't think I need use any of them for now. Note the revision field
in NCSI packet header is still 0x1, same to the one in the code.

   Command Number           Description
   0x1B                     Get Package Status
   0x51                     PLDM
   0x52                     Get Package UUID

>> 4. HW arbitration is disabled in this implementation. It should be
>> defined how to add support to system which supports HW arbitration.
>> 

It's good point. Yes, HW arbitration is disabled in select package command
in current implementation. It can be enabled only when all available packages
and channels claim the capability in the get capability response. Currently,
there are two fields ("active_package" and "active_channel") in NCSI interface
(struct ncsi_dev_priv). I can reuse them to distinguish those cases (enabled
and disable HW arbitration):

   Enabled: active_package = first_available_package, active_channel = NULL;
   Disable: active_package = package_in_work,         active_channel = channel_in_work;

It affects the behaviour how AENs are processed. I don't think we need enable AEN
messages any more if I'm correct enough here.

>> 5. The code has an initialization sequence which is clear. Yet there
>> shall be a re-initialization sequence needed if a device goes through
>> asynchronous entry to initial state, which may happen if the NIC goes
>> through reset for any reason.
>
>Ok.
>

Yes, It makes sense as AEN isn't mandatory function supported by NIC. I will
change the code accordingly in next revision.

>Gavin: We can discuss these tomorrow if you need.
>

Thanks, Ben. I will talk to you tomorrow when you have free time. Thank you
very much for kindly helps on this.

Thanks,
Gavin

>Cheers,
>Ben.
>
