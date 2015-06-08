From: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Subject: Re: [RFC net-next 0/3] Proposal for VRF-lite
Date: Mon, 8 Jun 2015 12:51:04 -0700
Message-ID: <CAJmoNQFMdN5purj9TsUAmuEExQy0tmENjS2CyTrkbqWneb+ziQ@mail.gmail.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com>
	<5575E964.7060308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jon Toppins <jtoppins@cumulusnetworks.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:33737 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048AbbFHTvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 15:51:05 -0400
Received: by wiwd19 with SMTP id d19so97107879wiw.0
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2015 12:51:04 -0700 (PDT)
In-Reply-To: <5575E964.7060308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Good catch, as you know I used to have the device getting modified in
the RX path and that made it all work

generic ip_rcv will need a fix to make RX visible to tcpdump, but yes,
that is the goal.

On Mon, Jun 8, 2015 at 12:13 PM, David Ahern <dsahern@gmail.com> wrote:
> On 6/8/15 12:35 PM, Shrijeet Mukherjee wrote:
>>
>> 5. Debugging is built-in as tcpdump and counters on the VRF device
>>     works as is.
>
>
> Is the intent that something like this
>
>   tcpdump -i vrf0
>
> can be used to see vrf traffic?
>
> vrf_handle_frame only bumps counters; it does not switch skb->dev to the vrf
> device so for Rx path tcpdump will not get the packets. ie., tcpdump only
> shows outbound packets.
