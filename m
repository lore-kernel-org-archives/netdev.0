From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next 00/10] NCSI Support
Date: Fri, 8 Jul 2016 02:34:22 +1000
Message-ID: <20160707163422.GA28500@gwshan>
References: <1467523953-18998-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <CAJ3xEMjEup1VUeCr3g2Ry78HvprfnC6wjGd=MWjnMOLWdLyKdQ@mail.gmail.com>
 <20160705174433.GA73415@ast-mbp.thefacebook.com>
 <CAJ3xEMgRqa_=MmPyRmOU=hUAF3o6N5A0dToa6hSwSut6QvosKw@mail.gmail.com>
 <1467883056.27157.28.camel@kernel.crashing.org>
 <CAJ3xEMg_gCT4rE=U3uX5tjqRarCLukKT9K2iFjsrk_7gwmwNHA@mail.gmail.com>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Gavin Shan <gwshan@linux.vnet.ibm.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, joel@jms.id.au,
	weixue@trustnetic.com, Yuval Itkin <yuvali@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:59034 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751035AbcGGQeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 12:34:31 -0400
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u67GYLR8109366
	for <netdev@vger.kernel.org>; Thu, 7 Jul 2016 12:34:30 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2415xnjw9v-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 12:34:29 -0400
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Fri, 8 Jul 2016 02:34:27 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 6BBC82BB005C
	for <netdev@vger.kernel.org>; Fri,  8 Jul 2016 02:34:24 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u67GYOue9699600
	for <netdev@vger.kernel.org>; Fri, 8 Jul 2016 02:34:24 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u67GYNWQ005039
	for <netdev@vger.kernel.org>; Fri, 8 Jul 2016 02:34:24 +1000
Content-Disposition: inline
In-Reply-To: <CAJ3xEMg_gCT4rE=U3uX5tjqRarCLukKT9K2iFjsrk_7gwmwNHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 07, 2016 at 04:44:02PM +0300, Or Gerlitz wrote:
>On Thu, Jul 7, 2016 at 12:17 PM, Benjamin Herrenschmidt
><benh@kernel.crashing.org> wrote:
>> On Thu, 2016-07-07 at 12:12 +0300, Or Gerlitz wrote:
>>> On Tue, Jul 5, 2016 at 8:44 PM, Alexei Starovoitov
>>> <alexei.starovoitov@gmail.com> wrote:
>>> > On Mon, Jul 04, 2016 at 01:03:06AM +0300, Or Gerlitz wrote:
>>>
>>> > Or, since cx4 has ncsi as well, could you do a thorough review of this
>>> > to make sure that it fits mellanox nics as well?
>>>
>>> Hi Alexei, all
>>>
>>> Yuval from our team who deals with host management did review on the
>>> series, SB his feedback.
>>>
>>> 1. The initialization uses a single unicast MAC address which hints it
>>> assumes that the management traffic is IPv4 only. The infrastructure
>>> does not seem to be ready for IPv6 based management traffic.
>>
>> You mean the transfer of the MAC address from the BMC to the NIC for
>> filtering incoming traffic ?
>
>The initialization sequence uses "Set MAC Command" once and
>initializes MAC[1] in the chosen NC-SI pass-through channel.
>If IPv6 is used, then the BMC multicast address (derived from the
>assigned IP address to the BMC) shall also be configured (after the IP
>address is assigned), and some multicast filtering shall be set as
>well.
>

Or, Thanks for the explanation. I think they are the multicast
MAC addresses (33:33:00:00:00:01/02/03)? I guess sending a Global
Multicast Filter Command is enough according to the NCSI spec
(line 2062 on page 93):

The Enable Global Multicast Filter command is used to activate global
filtering of multicast frames with optional filtering of specific multicast
protocols. Upon receiving and processing this command, the channel shall only
deliver multicast frames that match specific multicast MAC addresses enabled
for Pass through using this command ___or___ the Set MAC Address command.

Thanks,
Gavin
