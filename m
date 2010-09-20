From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: E1000E/82567LM-3: link reported up too soon
Date: Mon, 20 Sep 2010 23:28:57 +0200
Message-ID: <87aancqf3a.fsf@small.ssi.corp>
References: <878w2wnsyd.fsf@small.ssi.corp>
	<20100920.125447.220082714.davem@davemloft.net>
	<87y6awjhxv.fsf@small.ssi.corp>
	<20100920.131839.173838219.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: brian.haley@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:36083 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755051Ab0ITV2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Sep 2010 17:28:08 -0400
In-Reply-To: <20100920.131839.173838219.davem@davemloft.net> (David Miller's
	message of "Mon, 20 Sep 2010 13:18:39 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

David Miller <davem@davemloft.net> writes:

> From: arno@natisbad.org (Arnaud Ebalard)
> Date: Mon, 20 Sep 2010 22:09:16 +0200
>
>> The packets sent are an IPv6 Router Solicitation (to get IPv6 subnet
>> prefixes from the router) and a DHCP Request (to get an IPv4 address
>> from the DHCP server). 
>> 
>> The former is sent from the unspecified address (::) and the latter from
>> 0.0.0.0. The former is sent by UMIP Mobile IPv6 daemon. The second by my
>> DHCP client. They both use netlink to do that as soon as the link is up.
>> Both are for address configuration ...
>
> So do both DHCP request and the IPV6 RS get dropped, or just the IPV6 RS?

I added printk() to see where/if those first packets get dropped in
e1000e code. I followed those first packets to e1000_xmit_frame() and
don't see anything obvious happening there, i.e. they are passed to the
device as expected.

If I find some time tomorrow, I will try and take a look at
e1000_watchdog_task() and other functions that may perform asynchronous
tasks.

Cheers,

a+
