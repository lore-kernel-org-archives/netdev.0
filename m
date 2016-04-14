From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/2] rtnetlink: add new RTM_GETSTATS message
 to dump link stats
Date: Wed, 13 Apr 2016 23:36:09 -0700
Message-ID: <570F3A59.7010006@cumulusnetworks.com>
References: <1460183892-57286-2-git-send-email-roopa@cumulusnetworks.com> <20160410081650.GB22873@pox.localdomain> <570A9B4D.80104@cumulusnetworks.com> <570C7133.8070109@cumulusnetworks.com> <20160412132151.GA16560@pox.localdomain> <570E3784.9010809@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34531 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbcDNGgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 02:36:11 -0400
Received: by mail-pa0-f50.google.com with SMTP id ot11so42075628pab.1
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 23:36:11 -0700 (PDT)
In-Reply-To: <570E3784.9010809@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/13/16, 5:11 AM, Jamal Hadi Salim wrote:
> On 16-04-12 09:21 AM, Thomas Graf wrote:
>> On 04/11/16 at 08:53pm, roopa wrote:
>>> Top level stats attributes can be netdev or global attributes: We can include string "LINK" in
>>> the names of all stats belonging to a netdev to make it easier to recognize the netdev stats (example):
>>>   IFLA_STATS_LINK64,           (netdev)
>>>   IFLA_STATS_LINK_INET6,    (netdev)
>>>   IFLA_STATS_TCP,                (non-netdev, global tcp stats)
>>
>> This is fine as well. It means that we cant mix netdev and non-netdev
>> stats or stats for multiple netdevs in the same request which would
>> not be the case if you nest it and have a top level attribute which
>> is a list of requests. That may be borderline to overengineering
>> though so I'm fine this as well.
>
>
> Well - using a subheader which has ifindex on it for non-netdev stats
> seems wrong then.
I think its ok for ifindex to be optional.
Almost all msg types have subheaders with ifindex and it is almost always
optional in the GET request (eg RTM_GETLINK with NLM_F_DUMP ifindex is
optional and never checked). Here we make ifindex optional both ways.

Its optional in the GET request with NLM_F_DUMP and it is also optional
in the msg to userspace (NEW). And no ifindex in NEW will indicate that the
message is not tied to a specific netdev (ie global stats).

Thanks!
