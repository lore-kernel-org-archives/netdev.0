From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: Scaling Max IP address limitation
Date: Mon, 25 Jun 2007 11:47:31 +0300
Message-ID: <7e63f56c0706250147w508d3aeay5f7aaca8215953c8@mail.gmail.com>
References: <467EA7C1.4080006@rossove.com>
	 <20070624110236.fa36b2f9.akpm@linux-foundation.org>
	 <7e63f56c0706241259u6e123ed6yc02b76f0260adaa5@mail.gmail.com>
	 <467F063A.2030805@rossove.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Andrew Morton" <akpm@linux-foundation.org>
To: djones@rossove.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.239]:15527 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129AbXFYIrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 04:47:31 -0400
Received: by wx-out-0506.google.com with SMTP id t15so1395127wxc
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 01:47:31 -0700 (PDT)
In-Reply-To: <467F063A.2030805@rossove.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

On 6/25/07, David Jones <djones@rossove.com> wrote:

> >> > I am trying to add multiple IP addresses ( v6 ) to my FC7 box on eth0.
> >> > But I am hitting a max limit of 4000 IP address . Seems like there
> >> is a
> >> > limiting variable in linux kernel (which one? ) that prevents from
> >> > adding more IP addresses than 4096. What do I need to change in Linux
> >> > kernel  ( and then recompile ) to be able to add more IP addresses
> >> than 4K addresses per system? ..
> >
> I am using the "ip add " command looping sequentially up until RTNETLINK
> starts refusing to add more IP addresses.
> How are you adding via Netlink interface ?

Yes.

OK. Now it looks that I am reproducing something.

Running curl-loader with 60K.conf (edit the name of interface) configuration:
#ulimit -n 80000
#curl-loader -f ./conf-examples/60K.conf -w
 it adds successfully 60 000 secondary IPv4 addresses as seen by
#ip addr | wc -l

When I tryed adding IPv6 addresses, using ipv6.conf with addresses
range edited:
IP_ADDR_MIN=  2001:db8:fff5:1::1
IP_ADDR_MAX= 2001:db8:fff5:ffff::1

I am getting after initial successes some errors:
"rtnl_talk(): RTNETLINK answers: Cannot allocate memory"
and
#ip addr | wc-l is 8194.

8K addresses added and no more? It might be a memory issue. Y can dig
into the code and look into the allocation process and limits on the
kernel memory for IPv6.

The physical memory on my computer is 480 MB.
kernel is vanilla 2.6.20.7.

Try to see, what happens, when you increase the memory on your comp,
if an option.

-- 
Sincerely,
Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...........................................................
http://curl-loader.sourceforge.net
A web testing and traffic generation tool.
