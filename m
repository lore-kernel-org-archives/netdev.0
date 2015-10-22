From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] net: try harder to not reuse ifindex when moving
 interfaces
Date: Thu, 22 Oct 2015 17:23:38 +0200
Message-ID: <5628FF7A.5040807@6wind.com>
References: <20151021164613.24650836@griffin>
 <20151021.083214.534622235927401863.davem@davemloft.net>
 <20151021172502.63220dbb@griffin>
 <20151021.085635.1582760365341524949.davem@davemloft.net>
 <1445447578.1265325.416533273.3D5599FD@webmail.messagingengine.com>
 <5628F81D.1070009@6wind.com> <20151022170100.1e45a8b8@griffin>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	thaller@redhat.com
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:33473 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932409AbbJVPXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 11:23:41 -0400
Received: by wijp11 with SMTP id p11so37533835wij.0
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 08:23:40 -0700 (PDT)
In-Reply-To: <20151022170100.1e45a8b8@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/10/2015 17:00, Jiri Benc a =E9crit :
> On Thu, 22 Oct 2015 16:52:13 +0200, Nicolas Dichtel wrote:
>> With the proposed scenario:
>> 1. create netns 'new_netns'
>> 2. in root netns, move the interface with ifindex 2 to new_netns
>> 3. in new_netns, delete the interface with ifindex 2
>> 4. in new_netns, create an interface - it will get ifindex 2
>>
>> Operation 2 and 4 are done by dev_change_net_namespace() under rtnl_=
lock().
>> RTM_DELLINK(root netns) and RTM_NEWLINK(new_netns) are sent by this =
function.
>> It means that operation 3 has been done before and that RTM_DELLINK(=
new_netns)
>> has been sent before.
>
> Imagine the application trying to configure the interface with ifinde=
x 2
> after your step 2. It constructs a netlink message and sends it to th=
e
> kernel; but while doing so, steps 3 and 4 happen. Now the application
> ends up configuring a different interface than it intended to. After
> that, it polls the netlink socket and receives the notifications abou=
t
> interface disappearing and a new one appearing.
Understood.

>
> I don't see any way the user space application can prevent this. Ther=
e
> will always be a race between receiving netlink notifications and
> sending config requests.
Yeah, I'm also starting to think that reducing this window is the way t=
o go.


Thank you,
Nicolas
