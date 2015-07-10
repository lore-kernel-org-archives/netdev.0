From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC net-next 3/6] net: Introduce VRF device driver - v2
Date: Thu, 09 Jul 2015 20:39:53 -0600
Message-ID: <559F3079.1040203@cumulusnetworks.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>	<1436195001-4818-4-git-send-email-dsa@cumulusnetworks.com>	<CACP96tTyw+J7swi-+GJMwKKVjE9Uk1dJ3m_JKg2o1tyZup+p0w@mail.gmail.com>	<559EAD2A.2090002@cumulusnetworks.com> <CACP96tSp91XYo_UasZexb6c6Krru3LEJvDwEWSgKYgPHJmTkHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	ddutt@cumulusnetworks.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	hadi@mojatatu.com, "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
To: Sowmini Varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:37914 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbbGJCj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 22:39:57 -0400
Received: by igrv9 with SMTP id v9so3746681igr.1
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 19:39:56 -0700 (PDT)
In-Reply-To: <CACP96tSp91XYo_UasZexb6c6Krru3LEJvDwEWSgKYgPHJmTkHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/9/15 11:28 AM, Sowmini Varadhan wrote:
> On Thu, Jul 9, 2015 at 7:19 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>
>> On the to-do list to use cmsg to specify a VRF for outbound packets using
>> non-connected sockets. I do not believe it is going to work, but need to
>> look into it.
>>
>>> What about setting ipsec policy for interfaces in the vrf?
>
>  From a purely parochial standpoint, how would rds sockets work in this model?
> Would the tcp encaps happen before or after the the vrf "driver" output?
> Same problem for NFS.

If I set the VRF context (ie., set the SO_BINDTODEVICE for all sockets) 
of any RDS, NFS or any other socket app it runs in that VRF context and 
works just fine.

>
>  From a non-parochial standpoint. There are a *lot* of routing apps that actually
> need more visibility into many details about the "slave" interface: e.g., OSPF,
> ARP snoop, IPSLA.. the list is pretty long.
>
> I think it's a bad idea to use a "driver" to represent a table lookup. Too many
> hacks will become necessary.

Most of the changes needed to the networking stack are to address which 
table is used for FIB lookups. The stack has a strong preference to the 
local and main tables. I have a new patch set which better explains 
patch 4 in this version. I'll send it out in the next few days, but you 
can get a preview here:

   https://github.com/dsahern/linux.git, vrf-dev-4.1-v2 branch

David
