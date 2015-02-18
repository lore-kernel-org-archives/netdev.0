From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH RFC 1/2] net: dsa: integrate with SWITCHDEV for HW bridging
Date: Tue, 17 Feb 2015 22:14:44 -0800
Message-ID: <54E42DD4.1030803@roeck-us.net>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com> <1424201196-4901-2-git-send-email-f.fainelli@gmail.com> <20150218011955.GA17155@lunn.ch> <54E40CC9.2000505@roeck-us.net> <CAGVrzcZNEz6+peBAaSfadFf+wf9p=8EJ0yqBVZqAmnfEaPDFPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	jerome.oufella@savoirfairelinux.com,
	Chris Healy <cphealy@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:43921 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908AbbBRGPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 01:15:23 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YNxus-000Q26-Da
	for netdev@vger.kernel.org; Wed, 18 Feb 2015 06:15:22 +0000
In-Reply-To: <CAGVrzcZNEz6+peBAaSfadFf+wf9p=8EJ0yqBVZqAmnfEaPDFPA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/17/2015 08:53 PM, Florian Fainelli wrote:
> 2015-02-17 19:53 GMT-08:00 Guenter Roeck <linux@roeck-us.net>:
[...]
>
> I have put a v2 here which addresses that by retaining which bridge
> the port was added to and comparing that against the bridge net_device
> we want to join:
>
> https://github.com/ffainelli/linux/tree/dsa-hw-bridge-v2
>
>>
>> I don't really see the value in providing the port mask to
>> port_join_bridge, but maybe I am missing something. In my
>> implementation I just passed on bridge * and used it to
>> determine which port belongs to which bridge group.
>> It doesn't have to be that, but maybe we can use the bridge
>> ifindex or anything else that lets me determine which bridge
>> group the port belongs to.
>
> As I described in the cover letter, I tend to think that resolving
> this bitmask is part of the abstraction DSA should provide to its
> driver, maybe it is more future proof and better to give access to the
> bridge net_device pointer such that drivers can figure out the bridge
> details themselves. With that in mind, maybe we can do something like
> this:
>
> - add the bridge net_device pointer to the join/leave callbacks
> - provide a helper like dsa_slave_br_port_mask that drivers use or not
>
Not sure if that is needed.

At first glance v2 should do it. I only use the bridge pointer
to create a set of bit masks, one for each bridge group. This is
pretty much what you do now. So I should have the information I need,
and it should actually simplify my code to some degree.

Unfortunately I won't be able to work on this for the next few days,
since I'll be at the Linux Collaboration Summit in Santa Rosa.

Guenter
