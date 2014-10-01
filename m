From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Wed, 1 Oct 2014 14:12:34 -0700
Message-ID: <CAEP_g=8mYKypVS-MJeGnY4BGfPiu4zXRn-9--j5kntSFBe8Lnw@mail.gmail.com>
References: <1411962607-27878-1-git-send-email-therbert@google.com>
 <CAJ3xEMi-TRXevenx87UM7JnKqRQQATW4MBjbz8JdnQE9gk3KZw@mail.gmail.com>
 <CA+mtBx8r05=qs2J58LFq56762tFB7wF4Dsr3C5TC9w5qQP5jGw@mail.gmail.com>
 <CAJ3xEMhf6b75TQDFqEPMSXCpL9ToWG1q0OMPtrEuHNSm=-PSwQ@mail.gmail.com>
 <CA+mtBx_6HcZh5Ys1FJFBXkZ2bWX1gP6bTcjY7gbR6RG_TOy50Q@mail.gmail.com>
 <CAJ3xEMi0biCWTNtLOJ=0HWZYjOWi6pN2bw2=EWajp6XnpoyVRw@mail.gmail.com>
 <CA+mtBx-sP6g9hXAYGfHKCPYkCtjgCFM0srueh1uhoNnC2ACr1g@mail.gmail.com> <CAJ3xEMhc-97+3ZDwqXzX2N+=voO4QvJ5_YXn3sp8r8E9YyqotQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <therbert@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog020.obsmtp.com ([74.125.150.80]:33276 "HELO
	na6sys009bog020.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751598AbaJAVM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 17:12:57 -0400
Received: by mail-qa0-f53.google.com with SMTP id v10so893301qac.26
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 14:12:56 -0700 (PDT)
In-Reply-To: <CAJ3xEMhc-97+3ZDwqXzX2N+=voO4QvJ5_YXn3sp8r8E9YyqotQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 1, 2014 at 1:58 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>> Also, this does not benefit the stack or drivers that already support
>> generic SKB_GSO_UDP_TUNNEL mechanism.
>
> But again, we have 4-5 drivers that are
>
> 1. upstream
> 2. support GSO offloading under VXLAN
> 3. advertize GSO_UDP_TUNNEL
>
> As a starting point to stabilize the system (3.18 which has FOU and
> friends, merge window coming up while we are @ LPC) we can
>
> 1. add GSO_UDP_VXLAN_TUNNEL type
>
> 2. ask each maintainer to decide if they want to advertize the generic tunnel
> or only the vxlan specific one
>
> 3. color udp tunneled skb's with the tunnel type being vxlan or something else

There is no point in doing this. We should create a generic mechanism
that allows for drivers to assert some restrictions. For existing
drivers we can just provide an implementation of restrictions that is
pretty conservative and ask driver writers to take a look and loosen
it if possible. This is both cleaner and just as safe.
