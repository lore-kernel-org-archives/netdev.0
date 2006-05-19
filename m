From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH 3/4] myri10ge - Driver core
Date: Fri, 19 May 2006 17:48:31 +0200
Message-ID: <446DE8CF.7050603@myri.com>
References: <20060517220218.GA13411@myri.com> <446D2CA7.2070009@myri.com> <200605191200.47132.arnd@arndb.de> <200605191309.30992.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	gallatin@myri.com, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:16617 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S932406AbWESPtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 May 2006 11:49:03 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200605191309.30992.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> On Friday 19 May 2006 12:00, Arnd Bergmann wrote:
>   
>> On Friday 19 May 2006 04:25, Brice Goglin wrote:
>>     
>>> dev_mc_upload() from net/core/dev_mcast.c does
>>>
>>> spin_lock_bh(&dev->xmit_lock);
>>> __dev_mc_upload(dev);
>>>
>>> which calls dev->set_multicast_list(), which is
>>> myri10ge_set_multicast_list()
>>>
>>> which calls myri10ge_change_promisc
>>>
>>> which calls myri10ge_send_cmd
>>>       
>> Hmm, if that is the only path where you call it, it may be
>> helpful to change myri10ge_change_promisc to call a special
>> atomic version of myri10ge_send_cmd then, while all others
>> use the regular version, which you can then convert to
>> do msleep as well.
>>     
>
> Or just drop the xmit lock while you do that. As long as you
> handle races with ->start_xmit yourself it's ok
>   

Looks like we can do that.
Thanks,
Brice

