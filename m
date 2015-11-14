From: Joe Stringer <joestringer@nicira.com>
Subject: Re: OVS VXLAN decap rule has full match on TTL for the outer headers?
Date: Fri, 13 Nov 2015 22:45:15 -0800
Message-ID: <CANr6G5xe7URQgr=C7gL=xoAaUf5rXPQByBZscmNSVHyv2=+wRg@mail.gmail.com>
References: <56435508.9070802@mellanox.com> <CAEh+42jT44TQUcX=KOh9j495ObAJrQ1F_8YQF5Lz6CJUNkuh=w@mail.gmail.com>
 <CAJ3xEMhopRFPJFj4k41X6dKWz7Ok1Jqvtht7YS=59e3ceRf-qg@mail.gmail.com>
 <CAOftzPjio364zHUXSpK3uFDu+DiSc=5ae1WVjg9C+8485rpBsw@mail.gmail.com> <CAJ3xEMi5fPCd=v2UJN0CZB5948WpDuBm25rGW4yP6-q_QF31nw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>,
	Haggai Eran <haggaie@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ilya Lesokhin <ilyal@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:33367 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbbKNGpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2015 01:45:36 -0500
Received: by wmec201 with SMTP id c201so110206329wme.0
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2015 22:45:34 -0800 (PST)
In-Reply-To: <CAJ3xEMi5fPCd=v2UJN0CZB5948WpDuBm25rGW4yP6-q_QF31nw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13 November 2015 at 06:46, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Fri, Nov 13, 2015 at 10:14 AM, Joe Stringer <joestringer@nicira.com> wrote:
>
>> I don't follow the logic. You observed one flow which matched on
>> TTL=64, therefore all vxlan packets terminated at OVS have TTL=64?
>
>> If OVS received packets with different TTLs, they would miss and
>> ovs-vswitchd would generate flows to match that traffic too.
>
> ok, that makes things a bit better, but (see next)
>
>> If that becomes an issue, presumably the wildcard generation can be improved.
>
> is there a deep reason for vlxan "learned flows" to actually match w
> or w.o wild cards on TTLs?? for non-tunneled flow I don't see  this
> happening.

No deep reason I'm aware of.

>> I agree that this UNSPEC issue on v2.3 could do with a bit of a closer
>> look. I'll see if I can find some time for it. Alternatively if you're
>> willing and have bandwith, I'd be curious if it's related to the
>> masked set field feature introduced in Linux-4.0.
>
> so what would you suggest here? run with 3.19 or earlier?

On second thought, I think if it were related to that then userspace
v2.4 would not exhibit the problem. I'd have to dig in to see why it
occurs.
