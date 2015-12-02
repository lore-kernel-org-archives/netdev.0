From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 00/26] bonding/team offload + mlxsw
 implementation
Date: Wed, 2 Dec 2015 08:58:22 +0100
Message-ID: <20151202075822.GD2355@nanopsycho.orion>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
 <20151201144300.GB2165@nanopsycho.orion>
 <CAJ3xEMhMACJe_iK4PTrGwGFHzgGM=ccNKjVBoC6SUfCo0w7xFQ@mail.gmail.com>
 <20151201151243.GC2165@nanopsycho.orion>
 <CAJ3xEMjRQQoo=uU0qQ5Z9UmvS0_QjB2q_LUrpfBWLtTpHhd3qw@mail.gmail.com>
 <20151201164719.GA2548@nanopsycho>
 <CAJ3xEMiSA70nDsBWUmv=J6Cy2rt4+iNTg+4Yeqy=810etVAPZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>, yotamg@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>, pjonnala@broadcom.com,
	Jay Vosburgh <j.vosburgh@gmail.com>, vfalico@gmail.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	john fastabend <john.fastabend@gmail.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:33971 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752798AbbLBH6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 02:58:25 -0500
Received: by wmvv187 with SMTP id v187so241967648wmv.1
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 23:58:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMiSA70nDsBWUmv=J6Cy2rt4+iNTg+4Yeqy=810etVAPZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 02, 2015 at 06:53:35AM CET, gerlitz.or@gmail.com wrote:
>On Tue, Dec 1, 2015 at 6:47 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Tue, Dec 01, 2015 at 05:35:43PM CET, gerlitz.or@gmail.com wrote:
>>>On Tue, Dec 1, 2015 at 5:12 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> Tue, Dec 01, 2015 at 04:06:23PM CET, gerlitz.or@gmail.com wrote:
>>>>>On Tue, Dec 1, 2015 at 4:43 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>>>> Tue, Dec 01, 2015 at 02:48:38PM CET, jiri@resnulli.us wrote:
>
>>>>>>>This patchset introduces needed infrastructure for link aggregation
>>>>>>>offload - for both team and bonding. It also implements the offload
>>>>>>>in mlxsw driver.
>
>>>>>I didn't see any changes to switchdev.h, can you elaborate on that please.
>
>>>> Correct. This patchset does not extend switchdev api. The extension is
>>>> done for netdev notifiers. It seems natural and correct.
>>>> As we discussed already with John on a different thread, it makes sense
>>>> for non-switchdev drivers to benefit from this extensions as well.
>
>>>This is understood.
>
>>>However, the point which is still not clear to me related to the LAG /
>>>switchdev object model.
>
>>>All of FDB/VLAN/FIB switchdev objects have corresponding software counterparts
>>>in the kernel --- what's the case for LAG? the software construct is
>>>bond or team
>>>instance, shouldn't there  be a modeling of the HW LAG object in switchdev?
>
>> No need for that, what that would be good for?
>
>I'll give it 2nd thought, also lets see what other reviewers think on
>this matter.
>
>Another question relates to users bonding/teaming netdevice ports from
>different HW switches, or of two vlans over ports from the same HW switch.
>
>This is something that AFAIK not supported by HW -- do we want to
>disallow that?
>what layer in the kernel we want to enforce that limitation? team/bond
>or switchdev
>core or the switchdev HW driver?

It is not handled at the moment. In can be easily disallowed by driver.
