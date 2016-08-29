From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH] e1000: add initial XDP support
Date: Mon, 29 Aug 2016 06:53:53 -0400
Message-ID: <61de1b91-30b4-67ba-4192-834fa30757ea@mojatatu.com>
References: <20160827071145.25345.84712.stgit@john-Precision-Tower-5810>
 <b6cfb3c5-9c68-3ea7-48dd-7fbf666db751@mojatatu.com>
 <20160829103047.3968a4d8@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>, bblanco@plumgrid.com,
        davem@davemloft.net, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33547 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932244AbcH2Kx4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 06:53:56 -0400
Received: by mail-it0-f68.google.com with SMTP id d65so6116176ith.0
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 03:53:56 -0700 (PDT)
In-Reply-To: <20160829103047.3968a4d8@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-29 04:30 AM, Jesper Dangaard Brouer wrote:

> Hi Jamal,
>
> Can you please provide a simple "tc" command that implements "tc drop"?
>
> Then, I'll add this to the series of tests I'm using for (what I call)
> "zoom-in" benchmarking.
>

Thanks Jesper.

Something simple since this is done in ingress; lets say drop icmp
packets:

export ETH=eth0
export TC=/sbin/tc
#delete existing ingress qdisc - flushes all filters/actions
sudo $TC qdisc del dev $ETH ingress
#re-add ingress
sudo $TC qdisc add dev $ETH ingress
#
#simple rule to drop all icmp
sudo $TC filter add dev $ETH parent ffff: prio 4 protocol ip \
u32 match ip protocol 1 0xff flowid 1:1 \
action drop

# other type of filters if you want to compare instead of above
#
# a)drop all
sudo $TC filter add dev $ETH parent ffff: prio 2 protocol ip \
u32 match u32 0 0 flowid 1:1 \
action drop
#b) drop if src is XXX
sudo $TC filter add dev $ETH parent ffff: prio 2 protocol ip \
u32 match ip src 192.168.100.1 flowid 1:1 \
action drop

If you can do one core vs many cores (XDP should probably do very well
in multi-core)

I think given how ancient the e1000 is we may see the driver being
a contributing overhead. I believe XDP given location will do
well - but for this kind of driver my gut feeling is probably not
by large margin.

cheers,
jamal
