From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 0/3] switchdev: support stp updates on stacked
 netdevices
Date: Fri, 13 Mar 2015 18:49:10 -0700
Message-ID: <55039396.8060305@cumulusnetworks.com>
References: <1426206598-29410-1-git-send-email-roopa@cumulusnetworks.com> <20150313.001007.65274068513753002.davem@davemloft.net> <5502E544.7030003@cumulusnetworks.com> <20150313.123156.2118585119289960334.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:32923 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751056AbbCNBtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 21:49:12 -0400
Received: by pdnc3 with SMTP id c3so1833988pdn.0
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 18:49:12 -0700 (PDT)
In-Reply-To: <20150313.123156.2118585119289960334.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/13/15, 9:31 AM, David Miller wrote:
> From: roopa <roopa@cumulusnetworks.com>
> Date: Fri, 13 Mar 2015 06:25:24 -0700
>
>> David, if you mean not touch bond and team but have the switchdev
>> api do it transparently, yes, i had it that way initially.  And i do
>> liked it that way as well. But the feedback i received (during the
>> initial introduction of this for setlink/dellink) was to make it
>> explicit for each master.
> I think the concern is that we only want to do this for devices
> for which it is safe to "traverse" down like this.
>
> But frankly I cannot think of any layered device where we would
> not want to do this.
>
> Let's go back to the simple scheme where we unconditionally traverse
> and if we hit a problem case we'll figure out how to deal with it
> then, ok?
ok, sounds great. I will respin. Thanks!.

I wanted to move all three ops setlink/dellink/stpupdate initially, but 
now realize that
for something like the below to work, you will need the setlink/dellink 
support in the
bond and team driver because the call goes into the 'dev' driver 
directly without
calling into the switchdev api.

bridge link set dev bond0 learning off self

This case can be fixed too, however, it needs some more work in 
rtnetlink.c handling of 'self'.
The stp update api does not have this problem. I will respin the current 
stp update series first.
