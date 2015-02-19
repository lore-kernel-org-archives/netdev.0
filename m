From: roopa <roopa@cumulusnetworks.com>
Subject: Re: Port STP state after removing port from bridge
Date: Wed, 18 Feb 2015 20:54:02 -0800
Message-ID: <54E56C6A.1060108@cumulusnetworks.com>
References: <CAGVrzcZMV3vSd3hEsXqk6BtyU-Ts9=oJvb79DTZp25TnnGm5CQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@gmail.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:34718 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbbBSEyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 23:54:04 -0500
Received: by pdjg10 with SMTP id g10so6281734pdj.1
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 20:54:03 -0800 (PST)
In-Reply-To: <CAGVrzcZMV3vSd3hEsXqk6BtyU-Ts9=oJvb79DTZp25TnnGm5CQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/18/15, 8:39 PM, Florian Fainelli wrote:
> Hi,
>
> It just occured to me that the following sequence:
>
> brctl addbr br0
> brctl addif br0 port0
> ... STP happens
> brctl delif br0 port0
>
> will leave port0 in STP disabled state, because the bridge code will
> set the STP state to DISABLED, and only a down/up sequence can bring
> it back to FORWARDING.
>
> Is this something that we should somehow fix? As an user it seems a
> little convoluted having to do a down/up sequence to restore things. I
> believe however that it is valid for the bridge layer to mark a port
> as DISABLED when removing it. This is typically not noticed or even
> remotely a problem with software bridges because we cannot enforce an
> actual STP state at the HW level.
>
Just curious, Are you only talking about hw state being left it DISABLED 
state in the switchdev context ?.
If yes, then cant the switch driver who is already listening to port 
leave msgs, clear the disabled state on the port. ?
