From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net v3] ipv6: fix multipath route replace error recovery
Date: Tue, 08 Sep 2015 06:53:09 -0700
Message-ID: <55EEE845.60501@cumulusnetworks.com>
References: <1441572402-39024-1-git-send-email-roopa@cumulusnetworks.com> <55EE2EEA.5040109@cumulusnetworks.com> <55EEB086.7000100@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, mkubecek@suse.cz, Mazziesaccount@gmail.com,
	hannes@stressinduktion.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33850 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753193AbbIHNxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 09:53:11 -0400
Received: by padhy16 with SMTP id hy16so122771462pad.1
        for <netdev@vger.kernel.org>; Tue, 08 Sep 2015 06:53:11 -0700 (PDT)
In-Reply-To: <55EEB086.7000100@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/8/15, 2:55 AM, Nicolas Dichtel wrote:
> Le 08/09/2015 02:42, roopa a =E9crit :
>> On 9/6/15, 1:46 PM, Roopa Prabhu wrote:
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> Problem:
>>> The ecmp route replace support for ipv6 in the kernel, deletes the
>>> existing ecmp route too early, ie when it installs the first nextho=
p.
>>> If there is an error in installing the subsequent nexthops, its too=
=20
>>> late
>>> to recover the already deleted existing route
>>>
>>> This patch fixes the problem with the following:
>>> a) Changes the existing multipath route add code to a two stage=20
>>> process:
>>>    build rt6_infos + insert them
>>>     ip6_route_add rt6_info creation code is moved into
>>>     ip6_route_info_create.
>>> b) This ensures that all errors are caught during building rt6_info=
s
>>>    and we fail early
>>>
>> The other way I have been thinking of solving the problem is to mark=
=20
>> the sibling
>> routes being replaced with some state
>> ...so they can be restored on error. Still figuring out a way to do=20
>> this in a
>> clean and non-intrusive way.
> If I'm not wrong, the only error which may result to an inconsistent=20
> list of
> nexthops is ENOMEM (after your patch). I'm not sure it's worth to add=
=20
> too much
> complexity to the code to handle this error.
yes, agreed. And that's the reason i went down the  path presented in=20
the patch in context.
I was just reflecting back on the other possible implementations. thank=
s=20
for the review.
>
>> Or maybe  just save the sibling routes (rt6_infos) being replaced in=
=20
>> a list and
>> re-insert them on error.
> Yes, but we can also fail to re-insert the route.
ack.

posting v4 soon.
