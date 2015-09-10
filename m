From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net v4] ipv6: fix multipath route replace error recovery
Date: Wed, 09 Sep 2015 22:08:03 -0700
Message-ID: <55F11033.6090303@cumulusnetworks.com>
References: <1441734784-34416-1-git-send-email-roopa@cumulusnetworks.com> <20150909.141059.1681588831579060449.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, mkubecek@suse.cz,
	Mazziesaccount@gmail.com, hannes@stressinduktion.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35543 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbbIJFIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 01:08:06 -0400
Received: by pacfv12 with SMTP id fv12so32131129pac.2
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 22:08:06 -0700 (PDT)
In-Reply-To: <20150909.141059.1681588831579060449.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/9/15, 2:10 PM, David Miller wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> Date: Tue,  8 Sep 2015 10:53:04 -0700
>
>> This patch reduces the possibility of this by doing the following:
>> a) Changes the existing multipath route add code to a two stage process:
>>    build rt6_infos + insert them
>> 	ip6_route_add rt6_info creation code is moved into
>> 	ip6_route_info_create.
>> b) This ensures that most errors are caught during building rt6_infos
>>    and we fail early
>> c) Separates multipath add and del code. Because add needs the special
>>    two stage mode in a) and delete essentially does not care.
>> d) In any event if the code fails during inserting a route again, a
>>    warning is printed (This should be unlikely)
> Looks good, follows the usual "prepare/commit" paradigm.
>
> Applied, thanks.
>
> For net-next, it might be nice to make ip6_route_info_create() return
> error pointers instead of returning the rt pointer by reference.
ok, sounds good. Will post a patch with the error pointer to next-next 
when it opens. thanks.
