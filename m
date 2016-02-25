From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 3/4] net: sched: cls_u32 add bit to specify
 software only rules
Date: Thu, 25 Feb 2016 08:19:49 -0500
Message-ID: <56CEFF75.8070106@mojatatu.com>
References: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810>
 <20160223190321.5970.58924.stgit@john-Precision-Tower-5810>
 <20160224080440.GA26500@office.Home> <20160224084057.GC2151@nanopsycho.orion>
 <56CD701B.8070308@gmail.com> <20160224102907.05aa8e42@griffin>
 <56CE7E8A.3040202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, "Amir Vadai\"" <amir@vadai.me>,
	daniel@iogearbox.net, netdev@vger.kernel.org,
	alexei.starovoitov@gmail.com, davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>,
	Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34017 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760422AbcBYNTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 08:19:51 -0500
Received: by mail-io0-f193.google.com with SMTP id l127so5575916iof.1
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 05:19:50 -0800 (PST)
In-Reply-To: <56CE7E8A.3040202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-24 11:09 PM, John Fastabend wrote:
> On 16-02-24 01:29 AM, Jiri Benc wrote:
>> On Wed, 24 Feb 2016 00:55:55 -0800, John Fastabend wrote:
>>> The flags however likely stays with with TCA_U32_FLAGS until there is
>>> some better way to group common attributes in 'tc' framework.
>>
>> That's pretty bad, as this is uAPI and will need to be supported
>> forever. And having a different attribute in every filter won't ease
>> things for user space tools. I'd say we need the "better way" to be
>> added before this patchset.
>>
>>   Jiri
>>
>
> The 'tc' semantics seem to support this "pretty bad" API design
> with many of the fields already duplicated.

Mostly this is a netlink-ism. Netlink has the same problem with
command name spaces. The problem is mixing verbs and nouns together.
I like the switchdev approach where you have very few verbs
(SET, GET etc) and the content of the object or path describes
the nouns. This is why initially i thought it was better to have
this offload passing by switchdev. Could we leverage some of that?

> I suppose we could
> put the flags at the same level as the TCA_* attributes but this
> also doesn't seem right to me as it isn't actually handled until
> we get into the TCA_#CLASSIFIER#_* set of attributes.
>

Could we not steal a couple of bits off netlink flags? Then it applies
to all subssystems.

cheers,
jamal
