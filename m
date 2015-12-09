From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] net: Add fib rules at vrf device create
Date: Tue, 8 Dec 2015 20:08:31 -0700
Message-ID: <56679B2F.5080700@cumulusnetworks.com>
References: <1449607685-8910-1-git-send-email-dsa@cumulusnetworks.com>
 <20151208.214411.2137019448940208712.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34295 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498AbbLIDIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 22:08:36 -0500
Received: by pfbg73 with SMTP id g73so22727520pfb.1
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 19:08:35 -0800 (PST)
In-Reply-To: <20151208.214411.2137019448940208712.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/8/15 7:44 PM, David Miller wrote:
> Unfortunately it's too late for this, you should have considered this
> issue fully when VRF first went into an upstream release.
>
> If I add your change, the user experience is _worse_.
>
> Users on older kernels have to use the full sequence, then if they
> upgrade their kernels to one with this patch then the 'ru add' et
> al. commands will fail.
>

Perhaps this is another fug (feature bug), they do not fail:

root@kenny-jessie2:~# ip ru ls
0:	from all lookup local
32760:	from all iif vrf-green lookup vrf-green
32761:	from all oif vrf-green lookup vrf-green
32762:	from all iif vrf-blue lookup vrf-blue
32763:	from all oif vrf-blue lookup vrf-blue
32764:	from all iif vrf-red lookup vrf-red
32765:	from all oif vrf-red lookup vrf-red
32766:	from all lookup main
32767:	from all lookup default

root@kenny-jessie2:~# ip ru add oif vrf-red lookup vrf-red

root@kenny-jessie2:~# ip ru ls
0:	from all lookup local
32759:	from all oif vrf-red lookup vrf-red
32760:	from all iif vrf-green lookup vrf-green
32761:	from all oif vrf-green lookup vrf-green
32762:	from all iif vrf-blue lookup vrf-blue
32763:	from all oif vrf-blue lookup vrf-blue
32764:	from all iif vrf-red lookup vrf-red
32765:	from all oif vrf-red lookup vrf-red
32766:	from all lookup main
32767:	from all lookup default
