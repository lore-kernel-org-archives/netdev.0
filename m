From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4] af_mpls: fix undefined reference to ip6_route_output
Date: Tue, 28 Jul 2015 15:37:37 -0700
Message-ID: <55B80431.4070507@cumulusnetworks.com>
References: <1438065624-38229-1-git-send-email-roopa@cumulusnetworks.com> <1438088676.25794.19.camel@stressinduktion.org> <55B7D7FA.8070301@cumulusnetworks.com> <1438122163.2621886.335716241.03B1A616@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, tgraf@suug.ch, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:32870 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751058AbbG1Whi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:37:38 -0400
Received: by pdbnt7 with SMTP id nt7so77597362pdb.0
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 15:37:38 -0700 (PDT)
In-Reply-To: <1438122163.2621886.335716241.03B1A616@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/28/15, 3:22 PM, Hannes Frederic Sowa wrote:
> Hi roopa,
>
> On Tue, Jul 28, 2015, at 21:28, roopa wrote:
>>    ipv6_stub_impl.ipv6_dst_lookup seems to require sk today.
>> But it only needs it to get 'net' in the beginning and sk is optional
>> afterwards.
>> I will submit a patch to add 'net' as an arg  to ipv6_dst_lookup.
>> Users of ipv6_dst_lookup are few and that seems like an easy change and
>> helps my patch.
>> If you or others think otherwise, pls let me know.
> No need to extend this function at any cost. Simply add your own
> function pointer to the struct if needed.

saw your this email after I hit send on the series. Since the new 
function pointer will be exactly similar to ipv6_dst_lookup
with just an additional argument, a new function pointer does not seem 
necessary. But i can certainly change it
to a new function pointer and resend if that is more acceptable.
>
> Probably you have to move the ipv6_stub = &ipv6_stub_impl;
> initialization in inet6_init down so you don't expose the function
> pointer too early and thus it races with initialization (and error
> handling seems to be incorrect in this function, too).
>
ok, will look.

thanks,
Roopa
