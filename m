From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 1/2] fib: introduce fib notification
 infrastructure
Date: Tue, 6 Sep 2016 16:44:08 +0200
Message-ID: <20160906144408.GH1692@nanopsycho>
References: <1473163300-2045-1-git-send-email-jiri@resnulli.us>
 <1473163300-2045-2-git-send-email-jiri@resnulli.us>
 <6a4d9ba6-7113-b487-eb52-ca1f703d13f6@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, linville@tuxdriver.com, tgraf@suug.ch,
        gospo@cumulusnetworks.com, sfeldma@gmail.com, ast@plumgrid.com,
        edumazet@google.com, hannes@stressinduktion.org,
        f.fainelli@gmail.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@intel.com,
        andrew@lunn.ch, ivecera@redhat.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37644 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932279AbcIFOoT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 10:44:19 -0400
Received: by mail-wm0-f52.google.com with SMTP id w12so96570400wmf.0
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 07:44:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <6a4d9ba6-7113-b487-eb52-ca1f703d13f6@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 06, 2016 at 04:32:12PM CEST, dsa@cumulusnetworks.com wrote:
>On 9/6/16 6:01 AM, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> This allows to pass information about added/deleted fib entries to
>> whoever is interested. This is done in a very similar way as devinet
>> notifies address additions/removals.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  include/net/ip_fib.h | 19 +++++++++++++++++++
>>  net/ipv4/fib_trie.c  | 43 +++++++++++++++++++++++++++++++++++++++++++
>>  2 files changed, 62 insertions(+)
>> 
>
>The notifier infrastructure should be generalized for use with IPv4 and IPv6. While the data will be family based, the infra can be generic.
>

Yeah, that I thought about as well. Thing is, ipv6 notifier has to be
atomic. That is the reason we have:
inetaddr_chain and register_inetaddr_notifier (blocking notifier)
inet6addr_chain and register_inet6addr_notifier (atomic notifier)
