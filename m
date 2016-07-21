From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 0/9] mlxsw: implement port mirroring offload
Date: Thu, 21 Jul 2016 05:00:33 -0400
Message-ID: <83af7d8a-5f9c-aa3e-53cd-641cb175f66d@mojatatu.com>
References: <1469089160-4239-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, eladr@mellanox.com,
	idosch@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33965 "EHLO
	mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320AbcGUJAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 05:00:55 -0400
Received: by mail-lf0-f67.google.com with SMTP id l69so4923908lfg.1
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 02:00:54 -0700 (PDT)
In-Reply-To: <1469089160-4239-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-21 04:19 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> This patchset introduces tc matchall classifier and its offload
> to Spectrum hardware. In combination with mirred action, defined port mirroring
> setup is offloaded by mlxsw/spectrum driver.
>
> The commands used for creating mirror ports:
>
> # ingress mirroring using matchall
> tc qdisc  add dev eth25 handle ffff: ingress
> tc filter add dev eth25 parent ffff:            \
>         matchall skip_sw                        \
>         action mirred egress mirror             \
>         dev eth27
>
> # egress mirroring using matchall
> tc qdisc add dev eth25 handle 1: root prio
> tc filter add dev eth25 parent 1:               \
>         matchall skip_sw                        \
>         action mirred egress mirror             \
>         dev eth27
>


Kudos to Mellanox for all this nice work!

I am assuming the chip is capable as well of doing
mirroring via the ACL infrastructure and you are adding
this classifier because you are going via the SPAN
infrastructure. If answer is yes, thencould we have used
a classifier like u32 here?
i.e something like:
tc filter add dev eth25 xxxx protocol all \
u32 match u32 0 0 \
action mirred ...

BTW: I am not a big styling lawyer on netdev (I am normally the
victim) but would be useful to look at some of these patches with
that coding style in in mind (I think some of the chip specific
patches had some style issue in function definition).

again - kudos

cheers,
jamal
