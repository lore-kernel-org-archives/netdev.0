From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tcp wifi upload performance and lots of ACKs
Date: Mon, 04 Jun 2012 21:32:32 +0200
Message-ID: <1338838352.2760.1906.camel@edumazet-glaptop>
References: <4FCCFE76.3060304@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39068 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757257Ab2FDTci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 15:32:38 -0400
Received: by bkcji2 with SMTP id ji2so3935018bkc.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 12:32:36 -0700 (PDT)
In-Reply-To: <4FCCFE76.3060304@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-04 at 11:29 -0700, Ben Greear wrote:
> I'm going some TCP performance testing on wifi -> LAN interface connections.  With
> UDP, we can get around 250Mbps of payload throughput.  With TCP, max is about 80Mbps.
> 
> I think the problem is that there are way too many ACK packets, and bi-directional
> traffic on wifi interfaces really slows things down.  (About 7000 pkts per second in
> upload direction, 2000 pps download.  And the vast majority of the download pkts
> are 66 byte ACK pkts from what I can tell.)
> 
> Kernel is 3.3.7+
> 
> Anyone know of any tuning parameters that would let the receiving socket wait a
> bit longer and send more ACK data in fewer packets?

Well, thats half duplex days...

There is the ACK every 2 packets rule of thumb, so that tcp sender can
increase its cwnd.

Then, some folks tried submitting patches to make '2' more like 10 or
15, but this went nowhere.

Other idea is to arm a timer and defer ACK sending, in the hope we
receive another packet very soon.

That could be done with a special qdisc, sort of netem...
