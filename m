From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC net-next 3/6] net: Introduce VRF device driver - v2
Date: Thu, 09 Jul 2015 11:19:38 -0600
Message-ID: <559EAD2A.2090002@cumulusnetworks.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>	<1436195001-4818-4-git-send-email-dsa@cumulusnetworks.com> <CACP96tTyw+J7swi-+GJMwKKVjE9Uk1dJ3m_JKg2o1tyZup+p0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, shm@cumulusnetworks.com,
	roopa@cumulusnetworks.com,
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
Received: from mail-ie0-f170.google.com ([209.85.223.170]:32830 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752738AbbGIRTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 13:19:41 -0400
Received: by ietj16 with SMTP id j16so7902677iet.0
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 10:19:40 -0700 (PDT)
In-Reply-To: <CACP96tTyw+J7swi-+GJMwKKVjE9Uk1dJ3m_JKg2o1tyZup+p0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sowmini:

On 7/8/15 12:34 PM, Sowmini Varadhan wrote:
> Perhaps I misunderstand the design proposal here, but a switch's VRF
> is essentially just a separate routing table, whose input and output interfaces
> are exclusively bound to the VRF.

yes, and this model follows that.

>
> Can an application in the model above get visibiltiy into the (enslaved?)
> interfaces in the vrf?

yes. e.g., 'ip link show' prints the vrf device it is enslaved to:

6: swp3: <BROADCAST,MULTICAST,SLAVE> mtu 1500 qdisc noop master vrf10 
state DOWN mode DEFAULT group default qlen 1000
     link/ether 52:54:00:12:35:03 brd ff:ff:ff:ff:ff:ff
7: swp4: <BROADCAST,MULTICAST,SLAVE> mtu 1500 qdisc noop master vrf10 
state DOWN mode DEFAULT group default qlen 1000
     link/ether 52:54:00:12:35:04 brd ff:ff:ff:ff:ff:ff
8: swp5: <BROADCAST,MULTICAST,SLAVE> mtu 1500 qdisc noop master vrf10 
state DOWN mode DEFAULT group default qlen 1000
     link/ether 52:54:00:12:35:05 brd ff:ff:ff:ff:ff:ff
9: swp6: <BROADCAST,MULTICAST,SLAVE> mtu 1500 qdisc noop master vrf10 
state DOWN mode DEFAULT group default qlen 1000


> Can an application use IP_PKTINFO to send a packet out of
> a specific interface on a selected VRF? What about receiving
> IP_PKTINFO about input interface?

On the to-do list to use cmsg to specify a VRF for outbound packets 
using non-connected sockets. I do not believe it is going to work, but 
need to look into it.

> What about setting ipsec policy for interfaces in the vrf?
>

similarly, need to look at ipsec use cases with this vrf model.

David
