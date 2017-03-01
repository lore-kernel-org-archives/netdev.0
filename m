From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [Patch net v3] ipv6: check for ip6_null_entry in
 __ip6_del_rt_siblings()
Date: Wed, 1 Mar 2017 15:22:00 -0800
Message-ID: <8be0830c-7682-88fb-b186-6d661a6f115f@cumulusnetworks.com>
References: <1488240463-12000-1-git-send-email-xiyou.wangcong@gmail.com>
 <6d332a15-d86c-0b02-61e5-38d208f2caf7@cumulusnetworks.com>
 <20170301231648.2bpr7doxcipj5gi4@android-1601923ecb7aeff9.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Martin KaFai Lau <kafai@fb.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33272 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752979AbdCAX2m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 18:28:42 -0500
Received: by mail-pf0-f176.google.com with SMTP id w189so15362511pfb.0
        for <netdev@vger.kernel.org>; Wed, 01 Mar 2017 15:28:13 -0800 (PST)
In-Reply-To: <20170301231648.2bpr7doxcipj5gi4@android-1601923ecb7aeff9.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/1/17 3:16 PM, Martin KaFai Lau wrote:
> On Mon, Feb 27, 2017 at 04:14:04PM -0800, David Ahern wrote:
>> On 2/27/17 4:07 PM, Cong Wang wrote:
>>> Andrey reported a NULL pointer deref bug in ipv6_route_ioctl()
>>> -> ip6_route_del() -> __ip6_del_rt_siblings() code path. This is
>>> because ip6_null_entry is returned in this path since ip6_null_entry
>>> is kinda default for a ipv6 route table root node. Quote from
>>
>>
>> Missed this earlier. The issue here is an attempt to delete the NULL
>> route,
> You meant rt == NULL or rt->rt6i_table == NULL when rt == ip6_null_entry?

ip6_null_entry

> 
>> not that the null_entry is being returned as happens during a
>> route lookup. This will also hit the bug:
>>     ip -6 ro del ::/0
> I also found the commit log a bit confusing.  By reading the message,
> my first thought was an ip6_null_entry is returned because a route cannot
> be found.  Thanks for this particular test case.  It seems fn is NULL
> here for all random routes except 'ip -6 r del xyz::/0' which happens
> to match ip6_null_entry.

yes, that was my point.
