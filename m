From: "Venkata Jagana" <jagana@us.ibm.com>
Subject: Re: [PATCHSET] Mobile IPv6 for 2.5.45
Date: Fri, 1 Nov 2002 16:32:13 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF5B9EF40F.E3D52B05-ON88256C65.000191C7@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@wide.ad.jp, kkumar@beaverton.ibm.com.sgi.com,
   kuznet@ms2.inr.ac.ru, ajtuomin@tml.hut.fi, lpetande@tml.hut.fi,
   netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Hello Dave,

>Just like a router changes and monitors routes, a home agent daemon
>would change and monitor mipv6 state.  So for the same reason we don't
>put OSPF routing databases into the kernel, we do not put the home
>agent registration into the kernel :-)

I absolutely understand your concerns about keeping the Home Agent
registration in the kernel. However, I still believe that keeping
this code in userspace would cause problems for handoffs. (btw, this
code will never get executed on a regular host - only routers configured
as Home Agents would be running this code as a module).

Currently, when a Home Agent receives a registration request during the
Mobile Node's handoff mechanism, it needs to respond in a reasonably
quick time period so that the sessions on the MN can continue without
experiencing delays. Longer delays could be harmful for applications
such as VoIP, for which the latencies are quite critical.

By moving this registration process to userspace, we have no control
over when the home registration would complete, since there are no
guarantees when the home agent daemon would run. BTW, according to
ongoing discussions at Mobile IP WG, it is believed that even few
hundred millisecs of latencies are not acceptable to critical apps,
during which time the IP packet transfer is completely stopped.
With such latency issues, I still believe that moving the registration
to userspace would create issues for the MN.

Thanks,
Venkat

----------------------------------------------------------------
Venkata R Jagana
IBM Linux Technology Centre, Beaverton
jagana@us.ibm.com
Tel: (503) 578 3430 T/L 775-3430
