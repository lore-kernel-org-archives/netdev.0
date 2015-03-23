From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware forwarded
 packets
Date: Mon, 23 Mar 2015 10:12:45 -0700
Message-ID: <5510498D.5010001@cumulusnetworks.com>
References: <1426870714-3225-1-git-send-email-roopa@cumulusnetworks.com> <20150320.163655.474336751434677390.davem@davemloft.net> <550C92F3.50302@cumulusnetworks.com> <20150320220946.GB31769@lunn.ch> <20150323002215.GA6074@roeck-us.net> <550F6D7D.7030403@gmail.com> <550F8102.7040701@roeck-us.net> <550F8600.2020300@gmail.com> <550F8987.5070600@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	David Miller <davem@davemloft.net>, sfeldma@gmail.com,
	jiri@resnulli.us, ronen.arad@intel.com, netdev@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35257 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633AbbCWRMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 13:12:47 -0400
Received: by pagv19 with SMTP id v19so22435526pag.2
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 10:12:47 -0700 (PDT)
In-Reply-To: <550F8987.5070600@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/22/15, 8:33 PM, Guenter Roeck wrote:
> On 03/22/2015 08:18 PM, John Fastabend wrote:
> [ ... ]
>>
>> Sorry I probably wasn't being clear. I'm just saying we don't need to
>> have the driver tell us if the packet has been forwarded. All we have
>> to do in software is the switch check and assume all packets sent to us
>> from the driver have already been handled by the hardware. Roopa is
>> working on this I believe.
>>
>
> Ah, ok. Yes, you are correct. Sorry, I missed that.
yep, so my first RFC listed three ways to do this,
1) flag on the bridge port
2) check if the port being forwarded to is a switch port, using
             - the offload flag
             - the parent id (as john fastabend pointed out)
3) A per packet flag which switch driver sets indicating that the packet 
is hw forwarded.
     This is because we have run into cases where we want to move to 
software forwarding
     of certain packets like igmp reports.  (I will get some more 
details on the particular igmp problem).
     In such case, hardware punts the igmp packet to cpu and cpu will do 
the forwarding.
     I think we may hit more cases like this in the future.

my RFC v1 was based on 1). RFC v2 was based on 3) above.

But, for now, agree that we can just support the more common case using 2).
And, we can move to 3) in the future if needed.

thanks,
Roopa
