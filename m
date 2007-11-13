From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: possible bug in tcp_probe
Date: Tue, 13 Nov 2007 16:02:43 +0300
Message-ID: <20071113130243.GA4044@2ka.mipt.ru>
References: <20071113112615.GA7491@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:44855 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752394AbXKMNDR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 08:03:17 -0500
Content-Disposition: inline
In-Reply-To: <20071113112615.GA7491@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Tue, Nov 13, 2007 at 11:26:15AM +0000, Gavin McCullagh (Gavin.McCullagh@nuim.ie) wrote:
> 74.259589763 192.168.2.1 36988 192.168.3.5 5001 0x679c23dc 0x679bc3b4 18 13 9114624 78 76 10000 0 64
> 74.260590660 192.168.2.1 44261 192.168.3.5 5006 0x573bb3ed 0x573b700d 13 9 5254144 155 127 10000 0 64
> 74.261607478 192.168.2.1 44261 192.168.3.5 5006 0x588.066586741 192.168.2.1 33739 192.168.3.5 5009 0xe26d1767 0xe26cf577 2 3 13090816 443 15818 10000 0 64
> 88.066690797 192.168.2.1 33739 192.168.3.5 5009 0xe26d1767 0xe26cfb1f 3 3 13092864 2365 15818 10000 0 64
> 88.067625714 192.168.2.1 59385 192.168.3.5 5012 0x411c1090 0x411bd258 12 9 14578688 2807 15812 10000 0 64
> 
> As you can see the third line has been truncated as well as the next
> roughly 14 seconds of data after which data continues writing as usual.
> 
> I don't think my small changes are causing this but perhaps I'm wrong.
> Does anyone know what might be causing the above?

Log buffer has limited size, you can not write from different threads to
it and expect all data being printed synchronously, there is nothing
exceptional here.

-- 
	Evgeniy Polyakov
