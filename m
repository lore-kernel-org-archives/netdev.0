From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net-next 0/5] net_sched: Adjust qdisc_change() for command
 "#tc qdisc change/replace ..."
Date: Fri, 7 Mar 2014 10:29:44 +0800
Message-ID: <53192F18.9020900@huawei.com>
References: <1394111321-11192-1-git-send-email-yangyingliang@huawei.com> <20140307060818.fa549a2981b601bcec517227@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:20974 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbaCGC3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 21:29:50 -0500
In-Reply-To: <20140307060818.fa549a2981b601bcec517227@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/3/7 5:08, Hiroaki SHIMODA wrote:
> On Thu, 6 Mar 2014 21:08:36 +0800
> Yang Yingliang <yangyingliang@huawei.com> wrote:
> 
>> Current commands "#tc qdisc replace..." and "#tc qdisc change..."
>> are not doing what they're supposed to do.
>>
>> E.g.
>>
>> With "#tc qdisc replace ...", it won't clear old option if not specified in
>> qdisc of netem.
>>
>>    # tc qdisc add dev eth4 handle 1: root netem rate 10mbit
>>    # tc qdisc show
>>      qdisc netem 1: dev eth4 root refcnt 2 limit 1000 rate 10Mbit
>>
>>    # tc qdisc replace dev eth4 handle 1: root netem latency 10ms
>>    # tc qdisc show
>>      qdisc netem 1: dev eth4 root refcnt 2 limit 1000 delay 10.0ms rate 10Mbit
>> The old option "rate" is still there.
> 
> It looks like you are trying to replace existing qdisc 1: with
> the same qdisc 1:. So the effect is the same as change.
> If you want to do replace the existing qdisc, you should specify
> other handle or different qdisc.
> 
>> With "#tc qdisc change ... ", it will clear old options if not specified in
>> qdisc of tbf.
>>
>>   # tc qdisc add dev eth4 handle 1: root tbf rate 10mbit burst 10kb latency 50ms mtu 64kb peakrate 20mbit
>>   # tc qdisc show
>>     qdisc tbf 1: dev eth4 root refcnt 2 rate 10Mbit burst 10Kb peakrate 20Mbit minburst 64Kb lat 50.0ms
>>   # tc qdisc change dev eth4 handle 1: root tbf rate 20mbit burst 10kb latency 50ms
>>   # tc qdisc show
>>     qdisc tbf 1: dev eth4 root refcnt 2 rate 20Mbit burst 10Kb lat 50.0ms
>> The old peakrate and minburst are cleared.
> 
> You are assumed to implicitly specify "peakrate 0" at change.
> It seems that you are arguing the tc command, not kernel code.
> There would exist userland commmand whose rate and peakrate
> command options are always mandatory.
> How they support its command options is up to userland I think.
> 

peakrate is not specified, it should not be changed, I think.
peakrate is not mandatory.

I think tc command has no big problem and the real problem is kernel
code treats "change" as "replace", sometimes it treats "replace" as
"change".

Thanks!
