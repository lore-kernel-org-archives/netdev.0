From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: Using HTB over MultiQ
Date: Fri, 08 Nov 2013 15:11:34 -0800
Message-ID: <527D6FA6.5040508@intel.com>
References: <CAEzD07+Haf-Kg52H7GsxC5XiQn2KXozHbxgL4Lvn0grhFXVFmA@mail.gmail.com>  <1383833480.9412.58.camel@edumazet-glaptop2.roam.corp.google.com>  <1383834021.9412.61.camel@edumazet-glaptop2.roam.corp.google.com>  <527BA63F.7040900@intel.com>  <CAEzD07JwrnqeB35BiTC2ztpyei2KNDtYO8zuewicKNBwyxmOtQ@mail.gmail.com>  <1383923220.9412.236.camel@edumazet-glaptop2.roam.corp.google.com>  <527CFF2C.2020605@intel.com>  <CAEzD07LmgvvfNhNuxzwjy7fxLsCBLiofeXJ61qbdOBQCiSRefw@mail.gmail.com> <1383947802.16391.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anton 'EvilMan' Danilov <littlesmilingcloud@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:57369 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757919Ab3KHXLp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Nov 2013 18:11:45 -0500
In-Reply-To: <1383947802.16391.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/8/2013 1:56 PM, Eric Dumazet wrote:
> On Fri, 2013-11-08 at 19:53 +0400, Anton 'EvilMan' Danilov wrote:
>
>> Hm.. I think I need another way to classify packets for using of mq
>> qdisc, because it don't support classify at root (not supported error
>> on try attach filter).
>
> I think it might be time to add filters on the device, and run them
> without any lock (rcu protection only)
>
> John, I think you had some previous work ?

Yes, I have a net-next fork with this but I currently introduced a bug
in the u32 classifier. I'll resurrect this next week and send something
out. We can take a look and see if its useful.

>
>> On next week i'll try to write ipset extension for setting of priority
>> and queue_mapping value through the IPSET netfilter target.
>
> Sounds a nice idea as well.
>

Another thought would be to put a netfilter hook above the qdisc and on
ingress (not in the bridge module). I've been meaning to take a look
at nftables I'm not sure how much duplication exists between nftables
and tc classifiers at this point.

>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
