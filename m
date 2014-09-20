From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: action stats broken?
Date: Sat, 20 Sep 2014 08:21:28 -0700
Message-ID: <541D9B78.8070505@gmail.com>
References: <541D7E55.6070306@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john Fastabend <john.r.fastabend@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:60393 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbaITPVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 11:21:42 -0400
Received: by mail-oa0-f41.google.com with SMTP id i7so1034759oag.14
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 08:21:41 -0700 (PDT)
In-Reply-To: <541D7E55.6070306@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/2014 06:17 AM, Jamal Hadi Salim wrote:
>
> Sorry, dont have time to chase this today and it may be fixed in the
> latest  tree. Possibly recent patches or likely earlier patches
> even.
>
> It seems stats are no longer displaying for actions.
> This is a net-next kernel. I have tried kernel 3.16.0-rc2
> and 3.17.0-rc4 with same results.
>
> Simple test case:
>
> ----
> root@moja-1:~# tc actions add  action drop index 4
> root@moja-1:~# tc -s actions ls action gact
>
>      action order 0: gact action drop
>       random type none pass val 0
>       index 4 ref 1 bind 0 installed 9 sec used 4 sec
> -----
>
> What I would have expected to see is:
> ---
>      action order 0: gact action drop
>       random type none pass val 0
>       index 4 ref 1 bind 0 installed 9 sec used 4 sec
>           Sent 108948 bytes 1297 pkts (dropped 1297, overlimits 0)
> ---
>
>

I'm looking into it which classifier? A basic u32 classifier attached
to the ingress qdisc seems to work. If your using u32 any hash tables,
or 'filter change' commands before this?

# tc actions add  action drop index 4

# tc filter add dev p3p1 parent ffff:0 protocol ip prio 100 \
	u32 match ip src 16.0.0.2 action gact index 4

#tc -s actions ls action gact

         action order 0: gact action drop
          random type none pass val 0
          index 4 ref 2 bind 1 installed 142 sec used 0 sec
         Action statistics:
         Sent 840 bytes 10 pkt (dropped 10, overlimits 0 requeues 0)
         backlog 0b 0p requeues 0


> cheers,
> jamal
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
John Fastabend         Intel Corporation
