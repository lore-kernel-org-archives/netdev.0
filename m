From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2, RFC PATCH] flower: Represent HW traffic classes as
 classid values
Date: Tue, 31 Oct 2017 17:27:54 +0100
Message-ID: <20171031172754.56dc26af@shemminger-XPS-13-9360>
References: <150909706435.48576.5205367455065671596.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com,
        jiri@resnulli.us, jhs@mojatatu.com, alexander.duyck@gmail.com,
        xiyou.wangcong@gmail.com
To: Amritha Nambiar <amritha.nambiar@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:52043 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753697AbdJaQ2T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 12:28:19 -0400
Received: by mail-lf0-f52.google.com with SMTP id r129so19731020lff.8
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 09:28:18 -0700 (PDT)
In-Reply-To: <150909706435.48576.5205367455065671596.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Oct 2017 02:37:44 -0700
Amritha Nambiar <amritha.nambiar@intel.com> wrote:

> Use the classid values reserved in the range :ffe0 - :ffef
> to identify hardware traffic classes.
> 
> Example:
> Match Dst IPv4,Dst Port and route to TC1:
> # tc filter add dev eth0 protocol ip parent ffff:\
>   prio 1 flower dst_ip 192.168.1.1/32\
>   ip_proto udp dst_port 12000 skip_sw\
>   hw_tc 1
> 
> # tc filter show dev eth0 parent ffff:
> filter pref 1 flower chain 0
> filter pref 1 flower chain 0 handle 0x1 hw_tc 1
>   eth_type ipv4
>   ip_proto udp
>   dst_ip 192.168.1.1
>   dst_port 12000
>   skip_sw
>   in_hw
> 
> Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>

Not sure. Using reserved values can lead to future problems, but this
might be only simple way to handle this.
