From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000: power off PHY after reset when interface is down
Date: Fri, 4 Mar 2011 00:19:42 -0800
Message-ID: <AANLkTim-T99r+npYWCLH8ry+hbtCNBOM4WUev8soaoM6@mail.gmail.com>
References: <1298424313-9840-1-git-send-email-prasanna.panchamukhi@riverbed.com>
	<1298505765.25453.17.camel@jtkirshe-linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "prasanna.panchamukhi@riverbed.com"
	<prasanna.panchamukhi@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:35957 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688Ab1CDITn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 03:19:43 -0500
Received: by qyg14 with SMTP id 14so1754617qyg.19
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2011 00:19:43 -0800 (PST)
In-Reply-To: <1298505765.25453.17.camel@jtkirshe-linux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 23, 2011 at 16:02, Jeff Kirsher <jeffrey.t.kirsher@intel.co=
m> wrote:
> On Tue, 2011-02-22 at 17:25 -0800, prasanna.panchamukhi@riverbed.com
> wrote:
>> From: Prasanna S. Panchamukhi <prasanna.panchamukhi@riverbed.com>
>>
>> Some Phys supported by the e1000 driver do not remain powered off
>> across
>> a reset of the device when the interface is down, e.g. on 82546.
>> This patch powers down (only when WoL is disabled) the PHY after res=
et
>> if
>> the interface is down and ethtool diagnostics are not currently
>> running.
>>
>> Similar problem was see on 82571 controller and was fixed in e1000e
>> driver
>> by Bruce Allan.
>> Please refer commit 31dbe5b4ac6fca72dec946e4d0fa7f0913f1d9b1 for
>> details.
>>
>> Signed-off-by: Prasanna S. Panchamukhi
>> <prasanna.panchamukhi@riverbed.com>
>> ---
>> =C2=A0drivers/net/e1000/e1000_ethtool.c | =C2=A0 27 ++++++++++++++++=
+++--------
>> =C2=A0drivers/net/e1000/e1000_main.c =C2=A0 =C2=A0| =C2=A0 =C2=A07 +=
++++++
>> =C2=A02 files changed, 26 insertions(+), 8 deletions(-)
>
> Thanks Prasanna! =C2=A0I have added the patch to my queue of e1000 pa=
tches.
>

Prasanna-
Here is what we found during validating your patch:

The behavior of 82546 device(s) seems to be identical with/without this=
 patch
applied. 82546GB (LOM), dev_id 1079 powers down (with wol disabled) aft=
er
ifdown, but powers back up after approx. 10 seconds. 82546EB (NIC), dev=
_id
1010 powers down (with wol disabled) after ifdown. Both of the above
behaviors are the same with and without the patch applied. Also, if thi=
s patch
DID work as expected, it should print a message after a reset, such as =
"Cannot
restart autonegotiation: Resource temporarily unavailable", which would=
 mirror
the behavior of e1000e.

--=20
Cheers,
Jeff
