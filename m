From: "Zheng Jianping" <zjp@iscas.ac.cn>
Subject: Re: how ipv6 support multicast routing
Date: Thu, 7 Nov 2002 15:34:22 +0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <007601c28630$176125b0$6c06a8c0@zhengjp>
References: <Pine.LNX.4.44.0211070844230.8435-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Pekka Savola" <pekkas@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


----- Original Message -----
From: "Pekka Savola" <pekkas@netcore.fi>
To: "Zheng Jianping" <zjp@iscas.ac.cn>
Cc: <netdev@oss.sgi.com>
Sent: Thursday, November 07, 2002 2:45 PM
Subject: Re: how ipv6 support multicast routing



> have you looked at ip6_input.c/ip6_output.c already?  There's an
> (obsolete) ip6_mc_input function there, perhaps it might get you started.
> I recall usagi have made some minor modifications to it too, but I doubt
> it works.

Yes, I've looked at these files and did find ip6_mc_input function.
I add the following code to ip6_mc_input

#ifdef (CONFIG_IP6_MROUTE)
  int addr_type;
  addr_type = ipv6_addr_type(&hdr->daddr);
  if (!(addr_type & (IPV6_ADDR_LOOPBACK | IPV6_ADDR_LINKLOCAL))) {
   ip6_mr_input(skb);  /*defined in my 'ip6_mroute.c'*/
  }
#endif

But I don't knwo how to modify the functions in net/ip6/route.c, such as
ip6_route_input
ip6_route_output

and the funciton in net/ip6/ip6_output.c
ip6_output


> (I'd like to see PIM-SM work myself too.)
Is there somebody else doing the work of IPv6 multicast forwarding in Linux?

Thanks,
Zheng
