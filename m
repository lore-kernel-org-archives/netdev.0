From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next] tbf: handle gso skbs properly
Date: Fri, 15 Feb 2013 08:32:11 -0800
Message-ID: <1360945931.19353.13.camel@edumazet-glaptop>
References: <1360941882-6727-1-git-send-email-jiri@resnulli.us>
	 <1360944783.19353.9.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:59950 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932820Ab3BOQcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 11:32:15 -0500
Received: by mail-da0-f45.google.com with SMTP id w4so1480629dam.18
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 08:32:15 -0800 (PST)
In-Reply-To: <1360944783.19353.9.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-15 at 08:13 -0800, Eric Dumazet wrote:

> tc qdisc del dev eth0 root 2>/dev/null
> tc qdisc add dev eth0 root handle 10 tbf rate 0.5mbit burst 5kb latency 70ms peakrate 1mbit minburst 1540
> tc qd add dev eth0 parent 10: handle 20 fq_codel
> 
> I guess we need a per qdisc ops to reinject the packets at the right place.
> 

Or you could hold these packets in a private list (private to this TBF)
and dequeue packets from this private list before packets from child
qdisc.
