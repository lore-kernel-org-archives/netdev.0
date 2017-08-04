From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/2] tc actions: Improved batching and time
 filtered dumping
Date: Fri, 4 Aug 2017 13:17:41 -0700
Message-ID: <20170804131741.2145008c@xeon-e3>
References: <1501674387-15001-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, dsahern@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:36537 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751891AbdHDURo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 16:17:44 -0400
Received: by mail-pg0-f43.google.com with SMTP id v77so11877208pgb.3
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 13:17:44 -0700 (PDT)
In-Reply-To: <1501674387-15001-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  2 Aug 2017 07:46:26 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> dump more than TCA_ACT_MAX_PRIO actions per batch when the kernel
> supports it.
> 
> Introduced keyword "since" for time based filtering of actions.
> Some example (we have 400 actions bound to 400 filters); at
> installation time. Using updated when tc setting the time of
> interest to 120 seconds earlier (we see 400 actions):
> prompt$ hackedtc actions ls action gact since 120000| grep index | wc -l
> 400
> 
> go get some coffee and wait for > 120 seconds and try again:
> 
> prompt$ hackedtc actions ls action gact since 120000 | grep index | wc -l
> 0
> 
> Lets see a filter bound to one of these actions:
> ....
> filter pref 10 u32
> filter pref 10 u32 fh 800: ht divisor 1
> filter pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:10  (rule hit 2 success 1)
>   match 7f000002/ffffffff at 12 (success 1 )
>     action order 1: gact action pass
>      random type none pass val 0
>      index 23 ref 2 bind 1 installed 1145 sec used 802 sec
>     Action statistics:
>     Sent 84 bytes 1 pkt (dropped 0, overlimits 0 requeues 0)
>     backlog 0b 0p requeues 0
> ...
> 
> that coffee took long, no? It was good.
> 
> Now lets ping -c 1 127.0.0.2, then run the actions again:
> prompt$ hackedtc actions ls action gact since 120 | grep index | wc -l
> 1
> 
> More details please:
> prompt$ hackedtc -s actions ls action gact since 120000
> 
>     action order 0: gact action pass
>      random type none pass val 0
>      index 23 ref 2 bind 1 installed 1270 sec used 30 sec
>     Action statistics:
>     Sent 168 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
>     backlog 0b 0p requeues 0
> 
> And the filter?
> filter pref 10 u32
> filter pref 10 u32 fh 800: ht divisor 1
> filter pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:10  (rule hit 4 success 2)
>   match 7f000002/ffffffff at 12 (success 2 )
>     action order 1: gact action pass
>      random type none pass val 0
>      index 23 ref 2 bind 1 installed 1324 sec used 84 sec
>     Action statistics:
>     Sent 168 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
>     backlog 0b 0p requeues 0
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied to net-next branch. Thanks Jamal
