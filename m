From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 02/17] net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del
Date: Wed, 26 Nov 2014 06:54:26 -0500
Message-ID: <5475BF72.1060606@mojatatu.com>
References: <1416911328-10979-3-git-send-email-jiri@resnulli.us> <5474A25C.3080505@mojatatu.com> <5474A7EE.8000300@intel.com> <5474ABF0.60901@mojatatu.com> <5474AE9B.6000500@intel.com> <5474B353.10802@mojatatu.com> <CAE4R7bD1Hi+fnKp-Sg6Tn4AcpOu2pwgEYecP8LVA1ioO4FkgRQ@mail.gmail.com> <547546C5.3060207@mojatatu.com> <CAE4R7bA2VPZ3tm2MrsXAm4XfNX0TguT=vUma-3HrZSu98hBGyA@mail.gmail.com> <5475B952.2080500@mojatatu.com> <20141126114035.GM1875@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:45690 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbaKZLyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 06:54:31 -0500
Received: by mail-ig0-f174.google.com with SMTP id hn15so6730427igb.1
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 03:54:30 -0800 (PST)
In-Reply-To: <20141126114035.GM1875@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/14 06:40, Jiri Pirko wrote:
> Wed, Nov 26, 2014 at 12:28:18PM CET, jhs@mojatatu.com wrote:

>> Scott, you are gonna make do this all over again?;->
>> The summary is there are three possible policies that could be
>> identified by the user asking for a kernel operation.
>> One use case example was to send a bunch of (for example)
>> create/updates and request that the kernel should not abort on a
>> failure of a single one but to keep going and create/update as many
>> as possible. Is that part clear? I know it is not what you do,
>> but there are use cases for that (Read John's response).
>> Now assuming someone wants this and some entries failed;
>> how do you tell user space back what was actually updated vs not?
>> You could return a code which says "partial success".
>> Forget whether the table is keyed or indexed but if you wanted
>> to return more detailed info you would return an array/vector of some
>> sort with status code per entry. Something netlink cant do.
>> Is that a better description?
>
> Sure this is something that is reasonable to request. But that would
> require a major changes to userspace api. At this moment, when we are
> using the existing api, I would leave this out for phase 1. Let this be
> resolved later as a separate work. Does that make sense?
>

I think these are just discussions so we know where we are going.
I ACKed the patch already but added that we should consider these
policies. Scott take note.

The default behavior should be maintained whatever the new policies are.
The vectoring is going to be a harder thing to get right. It can be done
but long shot probably.
For user->kernel policy description, that is easy; we need 2 bits
from somewhere; probably same namespace as software/hardware.


cheers,
jamal
