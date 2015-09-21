From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: Re: [PATCH] ip: find correct route for socket which is not bound to a
 device
Date: Mon, 21 Sep 2015 10:04:59 +0800
Message-ID: <55FF65CB.1020205@oracle.com>
References: <1442385255-27014-1-git-send-email-wen.gang.wang@oracle.com>
 <20150917.212000.1163539662854684723.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39866 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755657AbbIUCDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 22:03:36 -0400
In-Reply-To: <20150917.212000.1163539662854684723.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Thanks for your review on this.

=E5=9C=A8 2015=E5=B9=B409=E6=9C=8818=E6=97=A5 12:20, David Miller =E5=86=
=99=E9=81=93:
> From: Wengang Wang <wen.gang.wang@oracle.com>
> Date: Wed, 16 Sep 2015 14:34:15 +0800
>
>> For multi-cast, we should find valid route(thus get the meaniful pmt=
u) for
>> the package on the socket which is not bound to a device(sk_bound_de=
v_if
>> being 0) too.
> Your patch breaks exactly the situation explained in full detail
> in the huge comment about the first change you are making:
>
> 			/* Special hack: user can direct multicasts
> 			   and limited broadcast via necessary interface
> 			   without fiddling with IP_MULTICAST_IF or IP_PKTINFO.
> 			   This hack is not just for fun, it allows
> 			   vic,vat and friends to work.
> 			   They bind socket to loopback, set ttl to zero
> 			   and expect that it will work.
> 			   From the viewpoint of routing cache they are broken,
> 			   because we are not allowed to build multicast path
> 			   with loopback source addr (look, routing cache
> 			   cannot know, that ttl is zero, so that packet
> 			   will not leave this host and route is valid).
> 			   Luckily, this hack is good workaround.
> 			 */
>
> That situation will now fail after your patch.

Yes, I noticed the above comment before I made the patch. I have=20
question regarding that
comment: Seems it's talking about the loopback source address(loopback=20
device interface
is with the index of 1). Do you think we can make something specific to=
=20
loopback device and
let the package with other outbound devices go through the routing cach=
e?


> So I cannot apply this patch, sorry.
>
> I know what you want, you want to end up with a cached route that
> will track the PMTU.
Yes, that's exactly what I want.
Actually the user space can work fine by adding a syscall=20
setsockopt(..., SO_BINDTODEVICE, ..) to
bind socket to the device. Well, the problem here is that there are a=20
lot of user space applications which
don't bind sockets and they are working fine with old kernel(2.6.39).=20
When moving to new kernel(4.x),
the problem appeared. And seems it's hard for force all of them change=20
to bind sockets and recompile.
  -- that's the pain.  Do you have any idea which won't break the=20
existing hack but can help with my case?

thanks,
wengang
