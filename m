From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v4 2/8] netdevice: add IPv4 fib add/del ops
Date: Mon, 9 Mar 2015 11:07:44 -0700
Message-ID: <CAE4R7bBMcSf3VO9bBpa5Fxus0FSk5S2akSCYX0HYGV3K+ixACQ@mail.gmail.com>
References: <1425619280-27492-1-git-send-email-sfeldma@gmail.com>
	<1425619280-27492-3-git-send-email-sfeldma@gmail.com>
	<54F9BFCB.5030100@mojatatu.com>
	<CAE4R7bAcfJ8M0eQMdZdS3aDgPVWSQznABZymGq+PU34vJx1suA@mail.gmail.com>
	<54FDA458.6040601@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:37859 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686AbbCISHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 14:07:45 -0400
Received: by qgdz107 with SMTP id z107so30507755qgd.4
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 11:07:44 -0700 (PDT)
In-Reply-To: <54FDA458.6040601@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 9, 2015 at 6:47 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 03/06/15 14:59, Scott Feldman wrote:
>>
>>
>> I considered passing netlink flags in to driver, but the kernel logic
>> in fib_table_insert() already takes care of the checks required by the
>> flags, and from the driver's perspective, only three ops are needed:
>> add, del, and mod.  And I've combined add and mod into the same op,
>> with the assumption the driver can know if an entry exists or not.
>>
>
> That assumption is not accurate. At least in some hardware i am working
> on right now a mod is cheaper than a create (and if i have to "know"
> wheter i should create or modify then i actually i have to query the
> hardware).

Good points Jamal (and Roopa), thanks for reviewing.  I'll send update
to pass in NLM_F_* flags.
