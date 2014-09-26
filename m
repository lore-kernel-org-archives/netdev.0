From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: tc rsvp filter show broke
Date: Fri, 26 Sep 2014 16:25:00 -0700
Message-ID: <5425F5CC.4070507@intel.com>
References: <5425A545.1040907@gmail.com> <5425ED2D.1000005@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:2195 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756007AbaIZX1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Sep 2014 19:27:19 -0400
In-Reply-To: <5425ED2D.1000005@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2014 03:48 PM, Jamal Hadi Salim wrote:
> On 09/26/14 13:41, John Fastabend wrote:
>> Hi Jamal,
>>
>> Here is another strange 'tc' result that I think is a
>> bug. If it was intended I can't see why. Show filter
>> commands on rsvp classifiers only list the first entry?
>>
> 
> Hrm  - poking inside there and this seems to be one of those
> classifiers that hasnt been getting a lot of love. Doesnt
> support actions well for example.
> 
> It seems to work for me:

This works for me as well try adding two or more policers and
check if they all get printed.

> ----------
> /sbin/tc -V
> tc utility, iproute2-ss140610
> 
> uname -a
> Linux jhs-1 3.16.0-rc2+ #4 SMP Fri Aug 29 11:13:53 EDT 2014 x86_64 x86_64 x86_64 GNU/Linux
> 
> sudo /sbin/tc qdisc add dev eth0 root handle 1:0 prio
> sudo /sbin/tc filter add dev eth0 pref 10 proto ip parent 1:0 rsvp session 10.0.0.1 ipproto icmp classid 1:1  police rate 1kbit burst 90k conform-exceed drop/ok
> /sbin/tc -s filter show dev eth0 parent 1:0
> filter protocol ip pref 10 rsvp
> filter protocol ip pref 10 rsvp fh 0x0001100a flowid 1:1 session 10.0.0.1 ipproto icmp
>  Sent 0 bytes 0 pkts (dropped 0, overlimits 0)
> 
> Now lets send a fast ping:
> sudo ping -f 10.0.0.1 -c 10000
> .......
> 10000 packets transmitted, 386 received, 96% packet loss, time 115495ms
> rtt min/avg/max/mdev = 0.300/0.499/1.262/0.164 ms, ipg/ewma 11.550/0.463 ms
> 
> /sbin/tc -s filter show dev eth0 parent 1:0
> filter protocol ip pref 10 rsvp
> filter protocol ip pref 10 rsvp fh 0x0001100a flowid 1:1 session 10.0.0.1 ipproto icmp
>  Sent 980000 bytes 10000 pkts (dropped 9614, overlimits 9614)
> 
> cheers,
> jamal
> 
> 
> 
> 
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
