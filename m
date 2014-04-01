From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] openvswitch: supply a dummy err_handler of
 gre_cisco_protocol to prevent kernel crash
Date: Tue, 1 Apr 2014 11:27:56 -0700
Message-ID: <CAEP_g=-an14xN7Q2fmC+wMk1G9WTAX+JrVeBx5QGnw2-XU3ezQ@mail.gmail.com>
References: <1395957398-24546-1-git-send-email-asuka.com@163.com>
 <CAEP_g=_qJ1uHKZmZdkUrT+NUkzbRgaHfShZoMbnnCb+LwjOneQ@mail.gmail.com>
 <4fd27e6c.c96a.14512e82018.Coremail.asuka.com@163.com> <CAEP_g=_84HXCZLOzQ0JdLBF5WVhqwTJeEAY-xjqDD8YCv8yrRg@mail.gmail.com>
 <3586fbc4.12f75.1451de4826d.Coremail.asuka.com@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: wei zhang <asuka.com@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog024.obsmtp.com ([74.125.150.88]:57372 "HELO
	na6sys009bog024.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751254AbaDAS2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 14:28:20 -0400
Received: by mail-ie0-f175.google.com with SMTP id to1so9618895ieb.34
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2014 11:28:16 -0700 (PDT)
In-Reply-To: <3586fbc4.12f75.1451de4826d.Coremail.asuka.com@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 1, 2014 at 8:24 AM, wei zhang <asuka.com@163.com> wrote:
> At 2014-04-01 08:49:53,"Jesse Gross" <jesse@nicira.com> wrote:
>>On Sun, Mar 30, 2014 at 5:12 AM, wei zhang <asuka.com@163.com> wrote:
>>> At 2014-03-29 06:02:25,"Jesse Gross" <jesse@nicira.com> wrote:
>
>>> Maybe I misunderstand something? I think if we discard all packet pass to us
>>> when we use gre vport, new gre_cisco_protocol which has lower priority could
>>> not see the packet intended to it.
>>
>>That's true but in this case it would also not see any data packets,
>>so I don't think that situation would work well anyways.
>>
>>> I checked the implementation of the ipgre_err(), which has be called before
>>> the err_handler of gre vport. It use the the (local address, remote address, key)
>>> to distinguish the packet which is realy intended to it, although it could not
>>> always get the key from the icmp packet. Should we do as the same as it?
>>> I'm not sure this is feasible, any advice is appreciate.
>>
>>OVS does flow based matching rather than using a static set of
>>configuration parameters, so everything "matches" in some way
>>(although the result might be to drop).
>
> So the flow based match could dynamically determine by the ovs daemon, we could
> not find out the belonging of the packet as far as we call ovs_dp_upcall(), isn't it?

That's right - and since the OVS flow table always has a default
behavior (even if it is drop or send to controller) there's never a
packet that isn't considered to be destined to OVS once it is
received.

If this makes sense to you, would you mind submitting the patch you
had earlier formally with a commit message and signed off by line?
