From: Daniel Walker <danielwa@cisco.com>
Subject: Re: ipv4: distinguish EHOSTUNREACH from the ENETUNREACH
Date: Mon, 14 Aug 2017 13:35:24 -0700
Message-ID: <a3d81771-62d2-f213-c98b-d9bb47cfb234@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>,
        "David S. Miller" <davem@davemloft.net>,
        Poornima Ranganath <pooranga@cisco.com>,
        xe-linux-external@cisco.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-5.cisco.com ([173.37.86.76]:9768 "EHLO
        rcdn-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752453AbdHNUor (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 16:44:47 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


It seems like commit cd0f0b is trying to add back these two errors 
values into ip_route_input_slow(). However, if you follow the code path 
further down you get to the two exit points of this function,

in net/ipv4/route.c:ip_route_input_slow()

if (rt_cache_valid(rth)) {
	skb_dst_set_noref(skb, &rth->dst);
	err = 0;
	goto out;
}

and

skb_dst_set(skb, &rth->dst);
err = 0;
goto out;

Both of these set "err" variable to 0. This effective destroys the 
return value which the patch seems to be adding. Am I missing something 
here?


Thanks,

Daniel
