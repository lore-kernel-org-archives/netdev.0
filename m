From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCHSET] Mobile IPv6 for 2.5.45
Date: Sat, 02 Nov 2002 12:00:19 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021102.120019.45396269.yoshfuji@linux-ipv6.org>
References: <OFCFEE31E7.E8F27031-ON88256C65.00068E7B@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, ajtuomin@tml.hut.fi, kkumar@beaverton.ibm.com.sgi.com,
   kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org, lpetande@tml.hut.fi,
   netdev@oss.sgi.com, jagana@us.ibm.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kumarkr@us.ibm.com
In-Reply-To: <OFCFEE31E7.E8F27031-ON88256C65.00068E7B@boulder.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OFCFEE31E7.E8F27031-ON88256C65.00068E7B@boulder.ibm.com> (at Fri, 1 Nov 2002 17:15:09 -0800), "Krishna Kumar" <kumarkr@us.ibm.com> says:

> When the HA gets a registration request, it needs to perform the following
> actions :
>         1. perform DAD
>         2. get the list of prefixes supported on the home link of the MN.
>         3. create a tunnel between the HA and the MN
>         4. join the solicited node multicast group of the MN's home
> address.
>         5. add the MN's home address to the list of proxy neigh cache entry
> for the HA.
>         6. Send NA on behalf of the MN
>         7. add the new location of the MN in the binding cache.
>         8. and finally send the Binding Registration Success/Failure
> message.
> 
> In the above list, the only activities which can be done in userspace are
> #7 and #8 (that I am aware of). The rest of the items can only be done in
> the
> kernel, atleast we need to move the support to kernel. If the HA
> registration
> is completely moved to userspace, it would still need these facilities (#1
> to #6) in the kernel to perform the actions for registration. So even with
> netlink
> we still need the infrastructure in the kernel.

1:     True:  we need some interface (and small code)
2:     FALSE: you CAN listen icmp6 message via raw socket.
3:     FALSE: you CAN create tunnel using raw socket;
              however, we think this is implemented in kernel.
4,5,6: True:  we need some interface to generate proxy ND.
              (proxy ND is already in kernel.)

For 1,4,5,6: "proxy address" on a device would be a solution.

--yoshfuji
