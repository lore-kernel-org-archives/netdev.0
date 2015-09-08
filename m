From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net v3] ipv6: fix multipath route replace error recovery
Date: Tue, 8 Sep 2015 11:55:18 +0200
Message-ID: <55EEB086.7000100@6wind.com>
References: <1441572402-39024-1-git-send-email-roopa@cumulusnetworks.com>
 <55EE2EEA.5040109@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mkubecek@suse.cz, Mazziesaccount@gmail.com,
	hannes@stressinduktion.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: roopa <roopa@cumulusnetworks.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:38093 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754180AbbIHJzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 05:55:33 -0400
Received: by wiclk2 with SMTP id lk2so108812841wic.1
        for <netdev@vger.kernel.org>; Tue, 08 Sep 2015 02:55:32 -0700 (PDT)
In-Reply-To: <55EE2EEA.5040109@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/09/2015 02:42, roopa a =E9crit :
> On 9/6/15, 1:46 PM, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> Problem:
>> The ecmp route replace support for ipv6 in the kernel, deletes the
>> existing ecmp route too early, ie when it installs the first nexthop=
=2E
>> If there is an error in installing the subsequent nexthops, its too =
late
>> to recover the already deleted existing route
>>
>> This patch fixes the problem with the following:
>> a) Changes the existing multipath route add code to a two stage proc=
ess:
>>    build rt6_infos + insert them
>>     ip6_route_add rt6_info creation code is moved into
>>     ip6_route_info_create.
>> b) This ensures that all errors are caught during building rt6_infos
>>    and we fail early
>>
> The other way I have been thinking of solving the problem is to mark =
the sibling
> routes being replaced with some state
> ...so they can be restored on error. Still figuring out a way to do t=
his in a
> clean and non-intrusive way.
If I'm not wrong, the only error which may result to an inconsistent li=
st of
nexthops is ENOMEM (after your patch). I'm not sure it's worth to add t=
oo much
complexity to the code to handle this error.

> Or maybe  just save the sibling routes (rt6_infos) being replaced in =
a list and
> re-insert them on error.
Yes, but we can also fail to re-insert the route.
