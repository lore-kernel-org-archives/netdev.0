From: Joe Stringer <joe@ovn.org>
Subject: Re: OVS VXLAN decap rule has full match on TTL for the outer headers?
Date: Wed, 2 Dec 2015 09:52:07 -0800
Message-ID: <CAOftzPi8mVWtr1aJ1EeAHjXOY7jq-WZ2XnNw5UAxO5_cQrVafA@mail.gmail.com>
References: <56435508.9070802@mellanox.com> <CAEh+42jT44TQUcX=KOh9j495ObAJrQ1F_8YQF5Lz6CJUNkuh=w@mail.gmail.com>
 <CAJ3xEMhopRFPJFj4k41X6dKWz7Ok1Jqvtht7YS=59e3ceRf-qg@mail.gmail.com>
 <CAOftzPjio364zHUXSpK3uFDu+DiSc=5ae1WVjg9C+8485rpBsw@mail.gmail.com>
 <CAJ3xEMi5fPCd=v2UJN0CZB5948WpDuBm25rGW4yP6-q_QF31nw@mail.gmail.com>
 <CANr6G5xe7URQgr=C7gL=xoAaUf5rXPQByBZscmNSVHyv2=+wRg@mail.gmail.com> <565AF849.8030008@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>, Jesse Gross <jesse@kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ilya Lesokhin <ilyal@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Joe Stringer <joe@ovn.org>
To: Haggai Eran <haggaie@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:46522 "EHLO
	slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964802AbbLBR7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 12:59:30 -0500
Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net [217.70.183.194])
	by slow1-d.mail.gandi.net (Postfix) with ESMTP id 4777C47E1F4
	for <netdev@vger.kernel.org>; Wed,  2 Dec 2015 18:52:32 +0100 (CET)
Received: from mfilter13-d.gandi.net (mfilter13-d.gandi.net [217.70.178.141])
	by relay2-d.mail.gandi.net (Postfix) with ESMTP id BDD61C5A7A
	for <netdev@vger.kernel.org>; Wed,  2 Dec 2015 18:52:29 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
	by mfilter13-d.gandi.net (mfilter13-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id MtAM-4wIaROK for <netdev@vger.kernel.org>;
	Wed,  2 Dec 2015 18:52:28 +0100 (CET)
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	(Authenticated sender: joe@ovn.org)
	by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 4DEFFC5A6D
	for <netdev@vger.kernel.org>; Wed,  2 Dec 2015 18:52:28 +0100 (CET)
Received: by ykfs79 with SMTP id s79so56224010ykf.1
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 09:52:27 -0800 (PST)
In-Reply-To: <565AF849.8030008@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29 November 2015 at 05:06, Haggai Eran <haggaie@mellanox.com> wrote:
> On 14/11/2015 08:45, Joe Stringer wrote:
>> On 13 November 2015 at 06:46, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>> > On Fri, Nov 13, 2015 at 10:14 AM, Joe Stringer <joestringer@nicira.com> wrote:
>>> >
>>>> >> I don't follow the logic. You observed one flow which matched on
>>>> >> TTL=64, therefore all vxlan packets terminated at OVS have TTL=64?
>>> >
>>>> >> If OVS received packets with different TTLs, they would miss and
>>>> >> ovs-vswitchd would generate flows to match that traffic too.
>>> >
>>> > ok, that makes things a bit better, but (see next)
>>> >
>>>> >> If that becomes an issue, presumably the wildcard generation can be improved.
>>> >
>>> > is there a deep reason for vlxan "learned flows" to actually match w
>>> > or w.o wild cards on TTLs?? for non-tunneled flow I don't see  this
>>> > happening.
>> No deep reason I'm aware of.
>
> Hi,
>
> We looked into the OVS kernel module, and apparently there's a check
> that rejects new tunnel flows if they don't have the TTL mask set [1].
>
> I was able to trace it to this commit [2] on the OVS tree, but I don't
> quite understand why the check was added. There was some discussion
> about the patch on the mailing list [3] that hints this was about
> catching zero TTL, but it has too little context for me to understand.
>
> I'm adding the author and reviewer of the patch, perhaps they can help
> explain this requirement.

I'm not the author or reviewer, but it seems like this is an attempt
to prevent flows from matching TTL=0 then proceeding to forward the
frame. You could still match a non-zero TTL with a wildcarded mask,
but it wouldn't be possible for a single flow to match all (non-zero)
TTL values.
