From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 11058] New: DEADLOOP in kernel network module
Date: Wed, 09 Jul 2008 17:00:33 +0200
Message-ID: <4874D291.1010707@trash.net>
References: <bug-11058-10286@http.bugzilla.kernel.org/> <20080708210014.a1d3baf8.akpm@linux-foundation.org> <4874B2DC.2070305@trash.net> <Pine.LNX.4.64.0807091519380.11391@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, hemao77@gmail.com,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63134 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824AbYGIPAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 11:00:37 -0400
In-Reply-To: <Pine.LNX.4.64.0807091519380.11391@blackhole.kfki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jozsef Kadlecsik wrote:
> On Wed, 9 Jul 2008, Patrick McHardy wrote:
> 
>> Good catch, thanks. Basically all del_timer()/timeout.function calls
>> in conntrack can happen in process context, so we'd have to disable
>> BHs every time we do this. I think this fix should also work. The
>> only spot where we return NF_REPEAT is in TCP conntrack, so we can
>> simply make sure we only do this if we actually managed to kill the
>> connection.
>>
>> Jozsef, what do you think?
> 
> I agree with you completely - and nice catch, indeed! Your proposed patch 
> looks just fine.

Thanks, I'll send a backport for 2.6.26 to Dave tonight.
