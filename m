From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] rtnetlink: delay RTM_DELLINK notification until
 after ndo_uninit()
Date: Tue, 02 Dec 2014 09:19:29 -0800
Message-ID: <547DF4A1.6070900@cumulusnetworks.com>
References: <1417499650-29176-1-git-send-email-maheshb@google.com>  <547DE418.9000309@cumulusnetworks.com>  <1417537150.5303.67.camel@edumazet-glaptop2.roam.corp.google.com>  <547DEBAC.5000005@cumulusnetworks.com> <1417539160.5303.73.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:36179 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754270AbaLBRTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 12:19:46 -0500
In-Reply-To: <1417539160.5303.73.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/2/14, 8:52 AM, Eric Dumazet wrote:
> On Tue, 2014-12-02 at 08:41 -0800, Roopa Prabhu wrote:
>
>> fair point. But the commit that moved things around was done to handle
>> cases where,
>> the ndo_uninit() already sends some notifications to userspace for the
>> changes
>> during uninit (example bond driver).
>>
>> The only point i was making was that the dellink after the ndo_uninit in
>> your
>> case now contains state that was prior to uninit for these drivers.
> I think Mahesh forgot to mention your patch probably broke some drivers.
>
> calling rtmsg_ifinfo() after uninit() is probably breaking dummy device,
> as it does :
>
> static void dummy_dev_uninit(struct net_device *dev)
> {
> 	free_percpu(dev->dstats);
> }
>
> It looks like 'fixing' ipvlan is not going to help.
>
> Instead of checking all drivers for such interesting side effects,
> and revert your patch, we had the idea of this solution.

ok fair enough. I could go through all drivers again and check and fix them.
but dont want to miss any such cases.
The patch idea is good.
Worth a comment in the source regarding the state in the dellink. 
Hopefully the drivers that are affected by this are very few.

Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Thanks!.
