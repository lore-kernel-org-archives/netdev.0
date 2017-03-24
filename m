From: "R. Parameswaran" <parameswaran.r7@gmail.com>
Subject: Re: [PATCH net-next v4 1/2] New kernel function to get IP overhead
 on a socket.
Date: Thu, 23 Mar 2017 18:51:44 -0700 (PDT)
Message-ID: <alpine.DEB.2.11.1703231809410.19388@vera100.eng.brocade.com>
References: <alpine.DEB.2.11.1703221554000.9002@vera100.eng.brocade.com> <20170323.150500.1211908608737471263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kleptog@svana.org, jchapman@katalix.com, davem@redhat.com,
        nprachan@brocade.com, rshearma@brocade.com,
        stephen@networkplumber.org, sdietric@brocade.com,
        ciwillia@brocade.com, lboccass@brocade.com, dfawcus@brocade.com,
        bhong@brocade.com, jblunck@brocade.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170323.150500.1211908608737471263.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Dave,

Please see inline:

On Thu, 23 Mar 2017, David Miller wrote:

> From: "R. Parameswaran" <parameswaran.r7@gmail.com>
> Date: Wed, 22 Mar 2017 15:59:13 -0700 (PDT)
> 
> > A new function, kernel_sock_ip_overhead(), is provided
> > to calculate the cumulative overhead imposed by the IP
> > Header and IP options, if any, on a socket's payload.
> > The new function returns an overhead of zero for sockets
> > that do not belong to the IPv4 or IPv6 address families.
> > 
> > Signed-off-by: R. Parameswaran <rparames@brocade.com>
> 
> Just use the IPv4/IPv6 header size for now, just like the VXLAN
> driver does.
>

Actually, that's how the original posting was - it was changed in 
response to a review comment from James Chapman requesting the IP
Options overhead to be factored in and for this to be calculated in
a new standalone function that can be reused in other situations. 
The review comment makes sense to me - the kernel seems to do a 
good job of accounting for the cumulative size of IP Options and
if the information is available, it may make sense to factor it in.

I guess you are concerned about compatibility between vxlan and
L2TP? There may be one difference  - the socket for vxlan
appears to be opened/controlled entirely within kernel code (seems
to call udp_sock_create() which does not appear to turn on any options), 
but in the case of L2TP, it is possible for the tunnel socket to be 
opened from user space, if a user space control plane daemon is running.
Regardless of how user space daemons are written right now, it is 
possible in theory for the user space code to turn on options on the 
L2TP tunnel socket. So it seems that IP options might be enabled on the 
L2TP socket, but are probably unlikely on the vxlan socket? 

I'd suggest giving this a few days for James to respond. 
At that time if there is agreement that we don't need to factor options, 
I can rework it.

thanks,

Ramkumar
  
 
> Thanks.
> 
