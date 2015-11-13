From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: OVS VXLAN decap rule has full match on TTL for the outer headers?
Date: Fri, 13 Nov 2015 16:46:22 +0200
Message-ID: <CAJ3xEMi5fPCd=v2UJN0CZB5948WpDuBm25rGW4yP6-q_QF31nw@mail.gmail.com>
References: <56435508.9070802@mellanox.com>
	<CAEh+42jT44TQUcX=KOh9j495ObAJrQ1F_8YQF5Lz6CJUNkuh=w@mail.gmail.com>
	<CAJ3xEMhopRFPJFj4k41X6dKWz7Ok1Jqvtht7YS=59e3ceRf-qg@mail.gmail.com>
	<CAOftzPjio364zHUXSpK3uFDu+DiSc=5ae1WVjg9C+8485rpBsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>,
	Haggai Eran <haggaie@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ilya Lesokhin <ilyal@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f193.google.com ([209.85.213.193]:33537 "EHLO
	mail-ig0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932148AbbKMOqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 09:46:24 -0500
Received: by igcqf20 with SMTP id qf20so2541186igc.0
        for <netdev@vger.kernel.org>; Fri, 13 Nov 2015 06:46:22 -0800 (PST)
In-Reply-To: <CAOftzPjio364zHUXSpK3uFDu+DiSc=5ae1WVjg9C+8485rpBsw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2015 at 10:14 AM, Joe Stringer <joestringer@nicira.com> wrote:

> I don't follow the logic. You observed one flow which matched on
> TTL=64, therefore all vxlan packets terminated at OVS have TTL=64?

> If OVS received packets with different TTLs, they would miss and
> ovs-vswitchd would generate flows to match that traffic too.

ok, that makes things a bit better, but (see next)

> If that becomes an issue, presumably the wildcard generation can be improved.

is there a deep reason for vlxan "learned flows" to actually match w
or w.o wild cards on TTLs?? for non-tunneled flow I don't see  this
happening.


> I agree that this UNSPEC issue on v2.3 could do with a bit of a closer
> look. I'll see if I can find some time for it. Alternatively if you're
> willing and have bandwith, I'd be curious if it's related to the
> masked set field feature introduced in Linux-4.0.

so what would you suggest here? run with 3.19 or earlier?


> In this case it looks like you created the datapath using a newer
> version of the userspace utilities, then without deleting the
> datapath, attempted to reuse the datapath with an older version of the
> userspace utilities. This is fine, but it warns you because it drops
> particular user features which the newer userspace supported (because
> the older userspace doesn't support them). Sure, it's not the most
> graceful, but it doesn't look fatal in and of itself. Comment from the
> code below for context:
>
> /* An outdated user space instance that does not understand
> * the concept of user_features has attempted to create a new
> * datapath and is likely to reuse it. Drop all user features.
> */

thanks for the clarification/s, yes, I tried few user-space versions
one after the other, possibly w.o deleting the datapath

>> So I now moved to 2.4.0, and things aren't much better... can you give
>> a quick try on
>> your systems for upstream kernel against upstream OVS w.r.t to simple
>> VXLAN config?

> What do you mean by "not much better"? Do you mean that you still
> observe one of the above three issues, or you see a different issue?
> In particular I'd be curious if you observe the UNSPEC issue.

I mean this is printed by ovs-dpctl dump-flows for the encap rule

recirc_id(0),in_port(3),eth(src=02:d3:6e:35:59:35,dst=9e:1e:90:87:27:1a),eth_type(0x0800),ipv4(tos=0/0x3,frag=no),
packets:111, bytes:10878, used:0.569s, actions:set(unspec(bad key
length 8, expected 0)(00 00 00 00 00 00 00 62)),2

Or.
