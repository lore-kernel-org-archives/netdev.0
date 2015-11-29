From: Haggai Eran <haggaie@mellanox.com>
Subject: Re: OVS VXLAN decap rule has full match on TTL for the outer headers?
Date: Sun, 29 Nov 2015 15:06:17 +0200
Message-ID: <565AF849.8030008@mellanox.com>
References: <56435508.9070802@mellanox.com>
 <CAEh+42jT44TQUcX=KOh9j495ObAJrQ1F_8YQF5Lz6CJUNkuh=w@mail.gmail.com>
 <CAJ3xEMhopRFPJFj4k41X6dKWz7Ok1Jqvtht7YS=59e3ceRf-qg@mail.gmail.com>
 <CAOftzPjio364zHUXSpK3uFDu+DiSc=5ae1WVjg9C+8485rpBsw@mail.gmail.com>
 <CAJ3xEMi5fPCd=v2UJN0CZB5948WpDuBm25rGW4yP6-q_QF31nw@mail.gmail.com>
 <CANr6G5xe7URQgr=C7gL=xoAaUf5rXPQByBZscmNSVHyv2=+wRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesse Gross <jesse@kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>,
	"Jesse Gross" <jesse@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ilya Lesokhin <ilyal@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	"Hadar Hen Zion" <hadarh@mellanox.com>,
	Jesse Gross <jesse@nicira.com>,
	"Pravin B Shelar" <pshelar@nicira.com>
To: Joe Stringer <joestringer@nicira.com>,
	Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0068.outbound.protection.outlook.com ([157.56.112.68]:49815
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750846AbbK2NVP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Nov 2015 08:21:15 -0500
In-Reply-To: <CANr6G5xe7URQgr=C7gL=xoAaUf5rXPQByBZscmNSVHyv2=+wRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/11/2015 08:45, Joe Stringer wrote:
> On 13 November 2015 at 06:46, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>> > On Fri, Nov 13, 2015 at 10:14 AM, Joe Stringer <joestringer@nicira.com> wrote:
>> >
>>> >> I don't follow the logic. You observed one flow which matched on
>>> >> TTL=64, therefore all vxlan packets terminated at OVS have TTL=64?
>> >
>>> >> If OVS received packets with different TTLs, they would miss and
>>> >> ovs-vswitchd would generate flows to match that traffic too.
>> >
>> > ok, that makes things a bit better, but (see next)
>> >
>>> >> If that becomes an issue, presumably the wildcard generation can be improved.
>> >
>> > is there a deep reason for vlxan "learned flows" to actually match w
>> > or w.o wild cards on TTLs?? for non-tunneled flow I don't see  this
>> > happening.
> No deep reason I'm aware of.

Hi,

We looked into the OVS kernel module, and apparently there's a check
that rejects new tunnel flows if they don't have the TTL mask set [1].

I was able to trace it to this commit [2] on the OVS tree, but I don't
quite understand why the check was added. There was some discussion
about the patch on the mailing list [3] that hints this was about
catching zero TTL, but it has too little context for me to understand.

I'm adding the author and reviewer of the patch, perhaps they can help
explain this requirement.

Regards,
Haggai

[1]
http://lxr.free-electrons.com/source/net/openvswitch/flow_netlink.c?v=4.3#L660
[2] datapath: More flexible kernel/userspace tunneling attribute.
    9b405f1aa8d175dc63ad3ffe5d0fe05d5ee09162
[3] http://openvswitch.org/pipermail/dev/2013-January/024573.html
