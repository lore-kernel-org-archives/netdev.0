From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Spinlock spinning in __inet_hash_connect
Date: Wed, 6 Mar 2013 11:10:06 +0000 (UTC)
Message-ID: <kh786e$r70$1@ger.gmane.org>
References: <CAKF7Hnf_EyF38OEKk2rJEvEvn+eftJ4CaHN7-SszqbZius81yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:44000 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757149Ab3CFLK3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 06:10:29 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UDCFB-0004c5-Go
	for netdev@vger.kernel.org; Wed, 06 Mar 2013 12:10:45 +0100
Received: from 180.129.197.13 ([180.129.197.13])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 12:10:45 +0100
Received: from xiyou.wangcong by 180.129.197.13 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 12:10:45 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 06 Mar 2013 at 09:52 GMT, Johannes Rudolph <johannes.rudolph@googlemail.com> wrote:
> Hello all,
>
> I hope I'm on the correct mailing list for raising this issue. We are
> seeing an issue while running a load test with jmeter against a web
> server [1]. The test suite uses 50 threads to connect to a localhost
> web server, runs one http request per connection and then loops. What
> happens is that after the test runs for about 10 seconds (~ 100000
> connections established / closed) the CPU load goes up and connection
> rates slow down massively (see [1] for a chart). With `perf top` I'm
> observing this on the _client_ side:
>
>  41.39%  [kernel]                                    [k] __ticket_spin_lock
>  16.83%  [kernel]                                    [k]
> __inet_check_established
>  12.50%  [kernel]                                    [k] __inet_hash_connect
>   4.35%  [kernel]                                    [k] __ticket_spin_unlock
>

It seems both IPv6 and IPv4 call paths contest for spin_lock(&head->lock),
so I am just wondering if we could use RCU to protect the iteration of
inet_bind_bucket_for_each().
