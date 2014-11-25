From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 02/17] net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del
Date: Tue, 25 Nov 2014 11:50:27 -0500
Message-ID: <5474B353.10802@mojatatu.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-3-git-send-email-jiri@resnulli.us> <5474A25C.3080505@mojatatu.com> <5474A7EE.8000300@intel.com> <5474ABF0.60901@mojatatu.com> <5474AE9B.6000500@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, edumazet@google.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:36551 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336AbaKYQuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 11:50:32 -0500
Received: by mail-ig0-f179.google.com with SMTP id r2so1033009igi.6
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 08:50:31 -0800 (PST)
In-Reply-To: <5474AE9B.6000500@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 11:30, John Fastabend wrote:
> On 11/25/2014 08:18 AM, Jamal Hadi Salim wrote:
>> On 11/25/14 11:01, John Fastabend wrote:
>>> On 11/25/2014 07:38 AM, Jamal Hadi Salim wrote:
>>>> On 11/25/14 05:28, Jiri Pirko wrote:
>>>>> Do the work of parsing NDA_VLAN directly in rtnetlink code, pass simple
>>>>> u16 vid to drivers from there.
>>>>>
>>>>


> Actually (after having some coffee) this becomes much more useful
> if you return which items failed. Then you can slam the hardware
> with your 100 entries, probably a lot more then that, and come back
> later and clean it up.
>

Yes, that is the general use case.
Unfortunately at the moment we only return codes on a netlink set
direction - but would be a beauty if we could return what succeeded
and didnt in some form of vector.
Note: all is not lost because you can always do a get afterwards and
find what is missing if you got a return code of "partial success".
Just a little less efficient..


> We return a bitmask of which operations were successful. So if SW fails
> we have both bits cleared and we abort. When SW is successful we set the
> SW bit and try to program the HW. If its sucessful we set the HW bit if
> its not we abort with an err. Converting this to (1) is not much work
> just skip the abort.
>

Ok, guess i am gonna have to go stare at the code some more.
I thought we returned one of the error codes?
A bitmask would work for a single entry - because you have two
options add to h/ware and/or s/ware. So response is easy to encode.
But if i have 1000 and they are sparsely populated (think an indexed
table and i have indices 1, 23, 45, etc), then a bitmask would be
hard to use.

cheers,
jamal
