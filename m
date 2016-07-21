From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/9] mlxsw: implement port mirroring offload
Date: Thu, 21 Jul 2016 11:07:07 +0200
Message-ID: <20160721090706.GA2171@nanopsycho.orion>
References: <1469089160-4239-1-git-send-email-jiri@resnulli.us>
 <83af7d8a-5f9c-aa3e-53cd-641cb175f66d@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
	eladr@mellanox.com, idosch@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35511 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140AbcGUJHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 05:07:11 -0400
Received: by mail-wm0-f48.google.com with SMTP id f65so14795641wmi.0
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 02:07:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <83af7d8a-5f9c-aa3e-53cd-641cb175f66d@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jul 21, 2016 at 11:00:33AM CEST, jhs@mojatatu.com wrote:
>On 16-07-21 04:19 AM, Jiri Pirko wrote:
>>From: Jiri Pirko <jiri@mellanox.com>
>>
>>This patchset introduces tc matchall classifier and its offload
>>to Spectrum hardware. In combination with mirred action, defined port mirroring
>>setup is offloaded by mlxsw/spectrum driver.
>>
>>The commands used for creating mirror ports:
>>
>># ingress mirroring using matchall
>>tc qdisc  add dev eth25 handle ffff: ingress
>>tc filter add dev eth25 parent ffff:            \
>>        matchall skip_sw                        \
>>        action mirred egress mirror             \
>>        dev eth27
>>
>># egress mirroring using matchall
>>tc qdisc add dev eth25 handle 1: root prio
>>tc filter add dev eth25 parent 1:               \
>>        matchall skip_sw                        \
>>        action mirred egress mirror             \
>>        dev eth27
>>
>
>
>Kudos to Mellanox for all this nice work!
>
>I am assuming the chip is capable as well of doing
>mirroring via the ACL infrastructure and you are adding
>this classifier because you are going via the SPAN

Yes, we are using span.

>infrastructure. If answer is yes, thencould we have used
>a classifier like u32 here?
>i.e something like:
>tc filter add dev eth25 xxxx protocol all \
>u32 match u32 0 0 \
>action mirred ...

That could be used. But I believe it is nicer to have explicit match-all
classifier for this case. That puts nice limit to what could be matched.


>
>BTW: I am not a big styling lawyer on netdev (I am normally the
>victim) but would be useful to look at some of these patches with
>that coding style in in mind (I think some of the chip specific
>patches had some style issue in function definition).

Could you point to that? checkpatch.pl does not say anything and I also
don't see anything.


>
>again - kudos

Thanks.

>
>cheers,
>jamal
