From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: OVS VXLAN decap rule has full match on TTL for the outer headers?
Date: Tue, 8 Dec 2015 23:23:31 +0200
Message-ID: <CAJ3xEMiVUqTw-0cykq1x+kv3xKeD463TgmqOHypvy+ybPOVndg@mail.gmail.com>
References: <56435508.9070802@mellanox.com>
	<CAEh+42jT44TQUcX=KOh9j495ObAJrQ1F_8YQF5Lz6CJUNkuh=w@mail.gmail.com>
	<CAJ3xEMhopRFPJFj4k41X6dKWz7Ok1Jqvtht7YS=59e3ceRf-qg@mail.gmail.com>
	<CAOftzPjio364zHUXSpK3uFDu+DiSc=5ae1WVjg9C+8485rpBsw@mail.gmail.com>
	<CAJ3xEMi5fPCd=v2UJN0CZB5948WpDuBm25rGW4yP6-q_QF31nw@mail.gmail.com>
	<CANr6G5xe7URQgr=C7gL=xoAaUf5rXPQByBZscmNSVHyv2=+wRg@mail.gmail.com>
	<CAJ3xEMiSwVhUCTYcH+nWWBqrSwiykqsBFUZtBkirQtzsXVVL4A@mail.gmail.com>
	<CAJ3xEMhzB3UzfeJ8rvCmDFG57QnG5wdHPfahthxgR7Y-vvaiQg@mail.gmail.com>
	<CAOftzPieLwrF2V5YknHBRHxpGSsHqvqDoiHFPvXEcp3NUe24Gw@mail.gmail.com>
	<CAPWQB7GmJNYwmu5fSOWeLQxhdfPR4WgaD-=F7ZQCd6PtmQ=oYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ilya Lesokhin <ilyal@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Tal Anker <Ankertal@mellanox.com>,
	Jarno Rajahalme <jarno@ovn.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:33486 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752594AbbLHVXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 16:23:32 -0500
Received: by iouu10 with SMTP id u10so39110286iou.0
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 13:23:31 -0800 (PST)
In-Reply-To: <CAPWQB7GmJNYwmu5fSOWeLQxhdfPR4WgaD-=F7ZQCd6PtmQ=oYQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 8, 2015 at 9:20 PM, Joe Stringer <joe@ovn.org> wrote:
> On 2 December 2015 at 10:01, Joe Stringer <joe@ovn.org> wrote:
>> On 29 November 2015 at 05:37, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>> On Thu, Nov 19, 2015 at 5:40 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>>> On Sat, Nov 14, 2015 at 8:45 AM, Joe Stringer <joestringer@nicira.com> wrote:
>>>>> On 13 November 2015 at 06:46, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>>>>> On Fri, Nov 13, 2015 at 10:14 AM, Joe Stringer <joestringer@nicira.com> wrote:
>>>>
>>>>>>> I agree that this UNSPEC issue on v2.3 could do with a bit of a closer
>>>>>>> look. I'll see if I can find some time for it. Alternatively if you're
>>>>>>> willing and have bandwith, I'd be curious if it's related to the
>>>>>>> masked set field feature introduced in Linux-4.0.
>>>>
>>>>>> so what would you suggest here? run with 3.19 or earlier?
>>>>
>>>>> On second thought, I think if it were related to that then userspace
>>>>> v2.4 would not exhibit the problem. I'd have to dig in to see why it
>>>>> occurs.
>>>>
>>>> Any findings?
>>>
>>> Hi Joe/Jesse,
>>>
>>> Apart from Haggai's note on the TTL, I am pinging you here for the 2nd
>>> time... can you please let me know how
>>> this goes on your end?

>> Apologies for the delayed response, we haven't found anything
>> interesting yet although we've mostly looked at plain set-field
>> actions with a combination of kernel/userspace versions. I plan to
>> carve out some time later this week to take another look.

> (resending due to teething issues with new email and plain-text, sorry
> for the spam)

> As far as the mask, I briefly discussed this with Jarno and it seems
> like it could be something as simple as zeroing the ip_ttl mask in
> tnl_wc_init().

to make sure I follow, will that have the consequence that we (user +
kernel) will practically not be testing the ttl for these flows?

> As far as the UNSPEC issue, I couldn't reproduce it. Are you sure that
> there weren't multiple versions of OVS installed, and while the OVS
> running was v2.3, your ovs-dpctl was an older version? I was running
> latest OVS branch-2.3 (c2e761f5b152).

OK, for the sake of double checking, I will do over-all cleanup and
re-check, but will be able to do that only next week.
