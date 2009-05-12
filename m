From: Daniel Robbins <drobbins@funtoo.org>
Subject: Re: [Bridge] [RFC 0/5] bridge - introduce via_phys_dev feature
Date: Tue, 12 May 2009 01:02:01 -0600
Message-ID: <de7adc5e0905120002o7f19a1eepe0397d698c08ce97@mail.gmail.com>
References: <20090511114639.440944109@openvz.org>
	 <de7adc5e0905112230r60254113t6b31d8114d141be@mail.gmail.com>
	 <aa79d98a0905112319k6bc19ebk60a6458165b8c0a1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net, xemul@openvz.org
To: Cyrill Gorcunov <gorcunov@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:18336 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753350AbZELHCB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 03:02:01 -0400
Received: by qw-out-2122.google.com with SMTP id 5so2074746qwd.37
        for <netdev@vger.kernel.org>; Tue, 12 May 2009 00:02:02 -0700 (PDT)
In-Reply-To: <aa79d98a0905112319k6bc19ebk60a6458165b8c0a1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is this functionality useful for OpenVZ? Do people need the ability to
do this? Why/when is it necessary for me to be able to add eth0 to a
bridge remotely?

I don't quite (yet) understand the usefulness of this feature. You
would still be very limited in what you can change with the network if
you are remote, right? That's why I don't quite understand the benefit
of this feature. How are you planning to use it? When I set up my
OpenVZ systems, I like to get the overall network/bridge configuration
perfect so that I don't need to make major changes when I am remote.

Again, I am not an expert so I am asking purely for my own curiosity.
I support the idea of making networking more flexible, but I do not
see this particular step addressed by the patch as a common need. That
may be due to my own lack of understanding.

I am a big fan of OpenVZ though, so if it helps OpenVZ in some way,
I'd like to know about it :)

-Daniel

On Tue, May 12, 2009 at 12:19 AM, Cyrill Gorcunov <gorcunov@openvz.org>=
 wrote:
> On 5/12/09, Daniel Robbins <drobbins@funtoo.org> wrote:
>> Note: I am not a bridge guru but I'm interested in understanding thi=
s
>> new functionality better. What is the larger benefit of this feature=
?
>> Does this make it possible to configure a bridge setup on a remote
>> system without losing connectivity? I can't do many kinds of network
>> changes remotely without risking losing connectivity (ie. changing I=
P
>> address, messing with routing, etc. -- it would be likely that you'd
>> lose network connectivity :) ) Therefore, I don't know if this is a
>> benefit unless it is needed for a particular application. Is this
>> useful for OpenVZ in some way?
>>
>> Regards,
>>
>> Daniel
>>
> Hi Daniel,
>
> The idea was exactly you described, ie have an ability to configure
> remote system as bridge. There was an example how to use it in the
> pach (last patch in series). Say we have remote system with eth0 set
> up and running. So we may sign in into this system remotely. If we
> have to confugure bridge on such a system (that even eth0 has to be
> the bridge port) we connect to this system via eth0 then add bridge
> br0 and run it via ifconfig br0 up, turn on via_phys_dev feature and
> evetually add eth0 as a bridge port. We will have small delay in
> session until port get forwarding state but after we could continue
> work remotely on the system without reconfiguring routing table. Even
> ssh session being used during configuration will continue operate. So
> except a delay no session interrupt. I hope, need a good testing ;)
>
>> On Mon, May 11, 2009 at 5:46 AM, Cyrill Gorcunov <gorcunov@openvz.or=
g>
>> wrote:
>>> Hi,
>>>
>>> here is RFC for new via_phys_dev bridge feature.
>>> In short -- it allows to use some bridge port as
>>> bridge itself with already configured routing table.
>>>
>>> More details with example you may found in patches.
>>>
>>> Please review. Any (including _complains_) comments are
>>> highly appreciated!
>>>
>>> The series is on top of current -net-next-2.6
>>>
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0| commit ed9b58bc443a1210b5be1ded6421b17=
e015bf985
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0| Author Richard Genoud <richard.genoud@=
gmail.com>
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0| Date Sat May 9 06:59:16 2009 +0000
>>>
>>> Cyrill
>>> _______________________________________________
>>> Bridge mailing list
>>> Bridge@lists.linux-foundation.org
>>> https://lists.linux-foundation.org/mailman/listinfo/bridge
>>>
>>
>
