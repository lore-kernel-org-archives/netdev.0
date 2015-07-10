From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC net-next 3/6] net: Introduce VRF device driver - v2
Date: Thu, 09 Jul 2015 21:44:43 -0600
Message-ID: <559F3FAB.6010603@cumulusnetworks.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>	<1436195001-4818-4-git-send-email-dsa@cumulusnetworks.com>	<CACP96tTyw+J7swi-+GJMwKKVjE9Uk1dJ3m_JKg2o1tyZup+p0w@mail.gmail.com>	<559EAD2A.2090002@cumulusnetworks.com>	<CACP96tSp91XYo_UasZexb6c6Krru3LEJvDwEWSgKYgPHJmTkHw@mail.gmail.com>	<559F3079.1040203@cumulusnetworks.com> <CACP96tQNsx4Za1Oy1Gkdwn5=t2cqWjJVunHQn7FSZZP75twSSA@mail.gmail.com>
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
Received: from mail-ig0-f169.google.com ([209.85.213.169]:34083 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293AbbGJDor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 23:44:47 -0400
Received: by igoe12 with SMTP id e12so27462551igo.1
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 20:44:46 -0700 (PDT)
In-Reply-To: <CACP96tQNsx4Za1Oy1Gkdwn5=t2cqWjJVunHQn7FSZZP75twSSA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/9/15 9:28 PM, Sowmini Varadhan wrote:
> On Fri, Jul 10, 2015 at 4:39 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
>
>> If I set the VRF context (ie., set the SO_BINDTODEVICE for all sockets) of
>> any RDS, NFS or any other socket app it runs in that VRF context and works
>> just fine
>
> What if the application wants to do SO_BINDTODEVICE?
>

We have knowledge of both -- vrf master and vrf slave. Do the checks 
from local up ... is there a socket bound to slave device? If yes, 
match. If no, check for socket bound to master (VRF device). If yes, 
match. If no, check global (only works for connected sockets).

David
