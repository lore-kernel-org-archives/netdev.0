From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC net-next 0/6] Proposal for VRF-lite - v2
Date: Thu, 9 Jul 2015 22:14:05 -0700
Message-ID: <CAE4R7bBuiXb=2qV+x4Fke5P_R6=C_=TxNfY0feOzbp44PNxKYg@mail.gmail.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jonathan Toppins <jtoppins@cumulusnetworks.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	ddutt@cumulusnetworks.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:35494 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526AbbGJFOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 01:14:25 -0400
Received: by oihr66 with SMTP id r66so148295281oih.2
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 22:14:25 -0700 (PDT)
In-Reply-To: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 6, 2015 at 8:03 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> In the context of internet scale routing a requirement that always
> comes up is the need to partition the available routing tables into
> disjoint routing planes. A specific use case is the multi-tenancy
> problem where each tenant has their own unique routing tables and in
> the very least need different default gateways.

Based on this problem statement, netns would be the answer: to
partition the physical router into N virtual routers.  If routing is
offloaded, the offload device is netns-aware to preserve the
partitioning down to the HW level.

I see from earlier discussions on VRF that netns is no good because
it's an inefficient use of resources.  I wonder if that's true in a
practical way?  If I have a 48-port router, I could create 24 2-port
virtual routers using netns, each running routing stuff (bgp, lldp,
ospf, etc).  Is the netns overhead plus the routing sw duplication not
going to fit on a Cumulus-class router?

In other words, if noone had ever heard of VRF, we'd conclude netns
given the problem statement.  And then focus on inefficiencies in
netns, if the implementation didn't fit a particular target.

So my C in RFC is what's wrong with using netns?  And can those wrongs be fixed?
