From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: IPv6 over Firewire
Date: Fri, 21 Dec 2012 19:39:54 +0100
Message-ID: <50D4ACFA.6040901@gmail.com>
References: <50D49659.1000101@gmail.com> <50D4A219.7080807@linux-ipv6.org>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f47.google.com ([209.85.214.47]:42293 "EHLO
	mail-bk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260Ab2LUSj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 13:39:58 -0500
Received: by mail-bk0-f47.google.com with SMTP id j4so2557462bkw.20
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 10:39:57 -0800 (PST)
In-Reply-To: <50D4A219.7080807@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> If you are talking about how to build NS/NA/RS/Redirect messages, you
> can just use ndisc_opt_addr_space() and ndisc_fill_addr_option() here.

Thanks, these functions are certainly helpful. But 
ndisc_opt_addr_space() calculates the required space from dev->addr_len 
and ndisc_addr_option_pad(dev->type). The latter is 0 for IEEE1394 
(firewire). So the required option space just comes from dev->addr_len, 
which is 8 for firewire, resulting in an option address space of 16 (2 
octets).

But rfc3146 requires an option address space of 3 octets. So my main 
question is if in such a situation the best is to reserve additional skb 
tail room using needed_tailroom in struct netdevice. This directly 
affects the memory allocated in ndisc_build_skb().

Regards,

Stephan
