From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: tc ingress filters not applied
Date: Mon, 06 Jul 2015 19:43:13 +0200
Message-ID: <559ABE31.9000405@iogearbox.net>
References: <20150330141523.GQ23551@haze> <loom.20150706T190215-28@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Huan Le <huan@apcera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54882 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbbGFRnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 13:43:16 -0400
In-Reply-To: <loom.20150706T190215-28@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/06/2015 07:24 PM, Huan Le wrote:
> Erik Hugne <erik.hugne <at> ericsson.com> writes:
>
>>
>> I'm having troubles with TC policing, the ingress filters does not seem to be
>> applied.
>>
>>
>> Kernel: net-next/latest
>> iproute2: shemminger/master
>>
>> //E
>>
>
> I observed similar behavior when configuring a filter on ingress qdisc.
> Test shows that traffic was rate-limited to the configured value.
> However, "tc filter show" does not show any filtering rule.
>
> (1) add ingress qdisc on eth1
> # tc qdisc add dev eth1 ingress
> # tc qdisc show dev eth1 ingress
> qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap \
>   1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> qdisc ingress ffff: parent ffff:fff1 ----------------
>
> (2) add filter under ingress qdisc
> # tc filter add dev eth1 parent ffff: protocol all \
>   u32 match ip src 0.0.0.0/0 \
>   police rate 256kbit burst 10k drop flowid :1
> # tc filter show dev eth1

You have to add the handle/parent here, otherwise this shows egress filters.

> (3) verified sch_ingress kernel module is installed
> # lsmod  | grep sch_ingress
> sch_ingress            12866  1
>
> (4) uname -a (if needed for debugging)
> Linux huan-lnx 3.16.0-30-generic #40~14.04.1-Ubuntu SMP
> Thu Jan 15 17:43:14 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux
>
> I am testing this using ubuntu 14.04 on a virtualbox VM
> (eth1 is a host-only adapter).
>
> Thanks,
> Huan
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
