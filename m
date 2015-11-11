From: Jesse Gross <jesse@kernel.org>
Subject: Re: OVS VXLAN decap rule has full match on TTL for the outer headers?
Date: Wed, 11 Nov 2015 14:44:32 -0800
Message-ID: <CAEh+42jT44TQUcX=KOh9j495ObAJrQ1F_8YQF5Lz6CJUNkuh=w@mail.gmail.com>
References: <56435508.9070802@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Stringer <joestringer@nicira.com>,
	Jesse Gross <jesse@nicira.com>,
	Haggai Eran <haggaie@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ilya Lesokhin <ilyal@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:33377 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752910AbbKKWoy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2015 17:44:54 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id C4944206B7
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 22:44:53 +0000 (UTC)
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6E1A620619
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 22:44:52 +0000 (UTC)
Received: by qgea14 with SMTP id a14so35240476qge.0
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 14:44:51 -0800 (PST)
In-Reply-To: <56435508.9070802@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 11, 2015 at 6:47 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> Hi Joe/Jesse,
>
> We've noticed that VXLAN decap rules set by OVS in the below trivial VXLAN
> config contain full match on TTL=64 for the outer headers, can you explain
> the reasoning behind it? is that justa typo in dumping the flow?

Looking at the code, this does indeed seem to be the case. To the best
of my knowledge, there was no particular reasoning behind it - it
simply was never an issue so the wildcard generation wasn't improved.

> I also noticed that on my systems (upstream kernel 4.3.0-rc6+, veth
> emulating a VM network 192.168.52/24 and host network 192.168.31/24, ovs
> user-space 2.3.2) something is broken in the encap rule reporting, traffic
> goes fine (below)

That is pretty strange, I have never seen that before. It seems that
the key to be set is being reported as UNSPEC, which is weird if
traffic is flowing normally. I guess you could try a newer version of
userspace but I'm not aware of any patches that went in that would
have fixed a bug in this area.
