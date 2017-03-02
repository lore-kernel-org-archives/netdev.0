From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [Patch net v3] ipv6: check for ip6_null_entry in
 __ip6_del_rt_siblings()
Date: Wed, 1 Mar 2017 16:07:38 -0800
Message-ID: <5ab5897d-bafe-d297-91da-07bc32ce6d6e@cumulusnetworks.com>
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
Received: from mail-pg0-f53.google.com ([74.125.83.53]:36605 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753553AbdCBAHy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 19:07:54 -0500
Received: by mail-pg0-f53.google.com with SMTP id s67so25431804pgb.3
        for <netdev@vger.kernel.org>; Wed, 01 Mar 2017 16:07:40 -0800 (PST)
In-Reply-To: <20170301231648.2bpr7doxcipj5gi4@android-1601923ecb7aeff9.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/1/17 3:16 PM, Martin KaFai Lau wrote:
> [ An unrelated topic.  I wonder ip -6 r del xyz::/0 would delete
>   the gateway route...]

a very related question ...

ip -6 r del x::/0 comes down to the kernel as delete '::/0' (plen is 0,
so cfg->fc_dst is 0). It ends up on the null_entry from fib6_locate b/c
of the 0 prefix length, so it is another variant of 'ip -6 ro del ::/0'
