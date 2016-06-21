From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [iproute PATCH v2 2/7] Use C99 style initializers everywhere
Date: Tue, 21 Jun 2016 11:13:11 -0600
Message-ID: <92a1938e-523f-533f-27c9-7ec881737472@cumulusnetworks.com>
References: <1466525921-15738-1-git-send-email-phil@nwl.cc>
 <1466525921-15738-3-git-send-email-phil@nwl.cc>
 <726e5c7d-f23b-dbf0-c1d4-721ef3d15d5b@cumulusnetworks.com>
 <20160621170333.GD19797@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Phil Sutter <phil@nwl.cc>,
	Stephen Hemminger <shemming@brocade.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36564 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752201AbcFUTuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 15:50:05 -0400
Received: by mail-pf0-f170.google.com with SMTP id t190so9579706pfb.3
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 12:50:04 -0700 (PDT)
In-Reply-To: <20160621170333.GD19797@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/21/16 11:03 AM, Phil Sutter wrote:
>> I downloaded CentOS 5 and 6. iproute2 fails to compile on CentOS 5.11;
>> ip command builds on 6.8 but with a flurry of redefinition errors
>> (BUILD_BUG_ON), but fails at tc.
>
> What's the exact error message please? Maybe some incompatibility in
> kernel headers? Although that shouldn't be ...

lib
     CC       libgenl.o
     CC       ll_map.o
     CC       libnetlink.o
     AR       libnetlink.a
     CC       utils.o
In file included from utils.c:35:
../include/utils.h:212:1: warning: "BUILD_BUG_ON" redefined
In file included from ../include/linux/netlink.h:4,
                  from ../include/linux/if_link.h:5,
                  from ../include/linux/netdevice.h:31,
                  from ../include/linux/if_arp.h:26,
                  from utils.c:28:
/usr/include/linux/kernel.h:29:1: warning: this is the location of the 
previous definition
...


     CC       tc_bpf.o
tc_bpf.c:41:26: error: linux/if_alg.h: No such file or directory
In file included from tc_bpf.c:45:
../include/utils.h:212:1: warning: "BUILD_BUG_ON" redefined
In file included from ../include/linux/netlink.h:4,
                  from ../include/libnetlink.h:7,
                  from ../include/utils.h:10,
                  from tc_bpf.c:45:
/usr/include/linux/kernel.h:29:1: warning: this is the location of the 
previous definition
make[1]: *** [tc_bpf.o] Error 1
make: *** [all] Error 2
