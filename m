From: Joe Stringer <joe@ovn.org>
Subject: Re: OVS VXLAN decap rule has full match on TTL for the outer headers?
Date: Thu, 10 Dec 2015 15:53:47 -0800
Message-ID: <CAPWQB7Fwjco+BCWv0Pbdtkcu7JkyFzqZ=JgSmK2moQP7N0dumw@mail.gmail.com>
References: <56435508.9070802@mellanox.com> <CAEh+42jT44TQUcX=KOh9j495ObAJrQ1F_8YQF5Lz6CJUNkuh=w@mail.gmail.com>
 <CAJ3xEMhopRFPJFj4k41X6dKWz7Ok1Jqvtht7YS=59e3ceRf-qg@mail.gmail.com>
 <CAOftzPjio364zHUXSpK3uFDu+DiSc=5ae1WVjg9C+8485rpBsw@mail.gmail.com>
 <CAJ3xEMi5fPCd=v2UJN0CZB5948WpDuBm25rGW4yP6-q_QF31nw@mail.gmail.com>
 <CANr6G5xe7URQgr=C7gL=xoAaUf5rXPQByBZscmNSVHyv2=+wRg@mail.gmail.com>
 <CAJ3xEMiSwVhUCTYcH+nWWBqrSwiykqsBFUZtBkirQtzsXVVL4A@mail.gmail.com>
 <CAJ3xEMhzB3UzfeJ8rvCmDFG57QnG5wdHPfahthxgR7Y-vvaiQg@mail.gmail.com>
 <CAOftzPieLwrF2V5YknHBRHxpGSsHqvqDoiHFPvXEcp3NUe24Gw@mail.gmail.com>
 <CAPWQB7GmJNYwmu5fSOWeLQxhdfPR4WgaD-=F7ZQCd6PtmQ=oYQ@mail.gmail.com>
 <CAJ3xEMiVUqTw-0cykq1x+kv3xKeD463TgmqOHypvy+ybPOVndg@mail.gmail.com>
 <CAPWQB7HkBFRozJzYNMDSZexJzmFVfDWc02Mkk1oTwwiCQtvPCg@mail.gmail.com>
 <CAJ3xEMgOh9busKb7c5WF32=umGf8EdauOwQ1d_eDTJP95V1XLA@mail.gmail.com>
 <CAPWQB7E=uJ2xyDeAPNKoeUdzpsO9AtYnph4ewfawvbN_NtRfSA@mail.gmail.com> <CAJ3xEMiF8-MyNW6iAq2RgH6ZMDrEJ4wMeNUJpSiSHUAdRLfZgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jarno Rajahalme <jarno@ovn.org>, Jesse Gross <jesse@kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ilya Lesokhin <ilyal@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Tal Anker <Ankertal@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:39368 "EHLO
	relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369AbbLJXyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 18:54:11 -0500
Received: from mfilter38-d.gandi.net (mfilter38-d.gandi.net [217.70.178.169])
	by relay5-d.mail.gandi.net (Postfix) with ESMTP id 0E65C41C084
	for <netdev@vger.kernel.org>; Fri, 11 Dec 2015 00:54:09 +0100 (CET)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
	by mfilter38-d.gandi.net (mfilter38-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id NyCcz8E-TKIk for <netdev@vger.kernel.org>;
	Fri, 11 Dec 2015 00:54:07 +0100 (CET)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	(Authenticated sender: joe@ovn.org)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id BD5E641C087
	for <netdev@vger.kernel.org>; Fri, 11 Dec 2015 00:54:07 +0100 (CET)
Received: by wmec201 with SMTP id c201so47224604wme.1
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2015 15:54:07 -0800 (PST)
In-Reply-To: <CAJ3xEMiF8-MyNW6iAq2RgH6ZMDrEJ4wMeNUJpSiSHUAdRLfZgg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10 December 2015 at 13:43, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Thu, Dec 10, 2015 at 11:23 PM, Joe Stringer <joe@ovn.org> wrote:
>> On 10 December 2015 at 13:06, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>> On Wed, Dec 9, 2015 at 2:22 AM, Joe Stringer <joe@ovn.org> wrote:
>
>>>>>> As far as the mask, I briefly discussed this with Jarno and it seems
>>>>>> like it could be something as simple as zeroing the ip_ttl mask in
>>>>>> tnl_wc_init().
>
>>>>> to make sure I follow, will that have the consequence that we (user +
>>>>> kernel) will practically not be testing the ttl for these flows?
>
>>>> Yes, it would cause userspace to 'wildcard' the field so the kernel
>>>> flows that are installed will ignore it during lookup.
>
>>> Cool, any chance this is gonna fit into your schedule to meet 4.4? if
>>> not, for 4.5?
>>> Also, can the patch be made simple/small enough to go into -stable as well?
>
>> It's a userspace change.
>
>
> mmm, in a downstream post of this thread [1] Haggai pointed to you
> that there's code in the OVS kernel path that that rejects new tunnel
> flows if they don't have the TTL mask set, so he's wrong? where?
>
> Or.
>
> [1] http://marc.info/?l=linux-netdev&m=144880328121156&w=2

The rejection is within an if statement called "if (!is_mask)", so it
seems to me like it is enforcing the flow key to specify a TTL value
(any), and doesn't care what the mask does.
