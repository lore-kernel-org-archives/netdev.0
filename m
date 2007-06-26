From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: Scaling Max IP address limitation
Date: Tue, 26 Jun 2007 16:58:15 +0200
Message-ID: <7e63f56c0706260758y728ef242o2262d2c1a0c97181@mail.gmail.com>
References: <467EA7C1.4080006@rossove.com>
	 <7e63f56c0706241259u6e123ed6yc02b76f0260adaa5@mail.gmail.com>
	 <467F063A.2030805@rossove.com>
	 <7e63f56c0706250147w508d3aeay5f7aaca8215953c8@mail.gmail.com>
	 <Pine.LNX.4.64.0706251130320.11964@fbirervta.pbzchgretzou.qr>
	 <7e63f56c0706250241q19c6cb49yb846a38eb10a53e6@mail.gmail.com>
	 <Pine.LNX.4.64.0706251437130.3137@fbirervta.pbzchgretzou.qr>
	 <7e63f56c0706250544u78353454y44f4aab12a9e3fa8@mail.gmail.com>
	 <467FFAAA.8010103@rossove.com>
	 <7e63f56c0706260756q504bc4c2sa8905fbaeed4308d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Andrew Morton" <akpm@linux-foundation.org>
To: djones@rossove.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.229]:61350 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827AbXFZO6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2007 10:58:16 -0400
Received: by wx-out-0506.google.com with SMTP id t15so1795059wxc
        for <netdev@vger.kernel.org>; Tue, 26 Jun 2007 07:58:15 -0700 (PDT)
In-Reply-To: <7e63f56c0706260756q504bc4c2sa8905fbaeed4308d@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On 6/25/07, David Jones <djones@rossove.com> wrote:
>  Ok I have tried it on a Pentium-M ( 32 Bit ,) with 512 MB RAM and  Core
> 2 Duo with 1Gig RAM  ( running SMP kernel , 2 CPUS) with same results.
> Cant go more than ~4K addresses. I have tried them with vanilla and
> custom kernels all  2.6.19+ versions.  Results are same on both systems ,
> so thats the reason I am thinking that there is some limit in kernel
>
> >> On Jun 25 2007 12:41, Robert Iakobashvili wrote:
> >> >> > I am getting after initial successes some errors:
> >> >> > "rtnl_talk(): RTNETLINK answers: Cannot allocate memory"
> >> >> > and
> >> >> > #ip addr | wc-l is 8194.
>

Looking into 2.6.20 sources:

IPv6 addresses are added via rtnetlink by:
inet6_rtm_newaddr ()
inet6_addr_add ()
ipv6_add_addr (),
where inet6_ifaddr structure is allocated by kzalloc ()

IPv4 addresses are added via rtnetlink by:
inet_rtm_newaddr () with further __inet_insert_ifa ()
inet_rtm_newaddr () allocates in_ifaddr structure by kzalloc ()

Structure inet6_ifaddr  is ~85-95 bytes (depending on config options,
arch, etc),
structure in_ifaddr is ~55-60 bytes (also depending). It looks like
the case, when
size does matter.
:)

When adding secondary IPv4 addresses from /proc/slabinfo is seen, that
slab "size-64" is used, whereas for IPv6 addresses "size-128" is in use.

There should be a way to make some fine tuning and, most probably, memory
allocation for the right pool (in your case "size-128").
I do recall some echo to /proc/slabinfo, but there were some evil details.

Probably, some great people of the netdev list can advise you, how to
increase memory resources in the right direction.
Hopefully it explains the facts and directs you.

Take care,


Sincerely,
Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...........................................................
http://curl-loader.sourceforge.net
A web testing and traffic generation tool.
