From: andrew hendry <andrew.hendry@gmail.com>
Subject: Re: [PATCH 8/8] x25: use limited socket backlog
Date: Thu, 4 Mar 2010 09:44:49 +1100
Message-ID: <d45a3acc1003031444y43e0a862ta534b7c7ef4329e5@mail.gmail.com>
References: <1267598111-12503-1-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-4-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-5-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-6-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-7-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-8-git-send-email-yi.zhu@intel.com>
	 <1267600109.2839.101.camel@edumazet-laptop>
	 <d45a3acc1003030338m3102a95p1b06b7db1b24e58e@mail.gmail.com>
	 <DA586906BA1FFC4384FCFD6429ECE860A45A6992@shzsmsx502.ccr.corp.intel.com>
	 <1267626781.2997.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Zhu, Yi" <yi.zhu@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f182.google.com ([209.85.223.182]:42119 "EHLO
	mail-iw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487Ab0CCWou convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 17:44:50 -0500
Received: by iwn12 with SMTP id 12so1587256iwn.21
        for <netdev@vger.kernel.org>; Wed, 03 Mar 2010 14:44:49 -0800 (PST)
In-Reply-To: <1267626781.2997.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thinking like someone trying to break it, it may be possible for X25
to flood backlog.
With specific environments, enough circuits XoT/XoE may be able to.
Also tun + TUNSETLINK and some userspace code it might be possible. A
limit should be set just in case, and to cover X25 normal use it
doesn't need to be very big. 256 seems reasonable to start.
I'll look at setting up a fast virtual x.25 environment to test its
backlog behavior.

I think resolve issue for common protocols first, I don't know if
X25=3Dm would be used widely.

Andrew.

On Thu, Mar 4, 2010 at 1:33 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mercredi 03 mars 2010 =E0 22:00 +0800, Zhu, Yi a =E9crit :
>> andrew hendry <andrew.hendry@gmail.com> wrote:
>>
>> > Will wait for the next spin and in the meantime think if there is =
way
>> > to test it. x25 with no loopback and being so slow probably cant g=
enerate the same
>> > as your UDP case.
>>
>> I didn't find a way to drop the packet correctly. So I didn't change=
 any behavior in
>> this patch. Nor did I do in the second spin. It will be fine if you =
also think x25 doesn't
>> need to limit its backlog size.
>
> So are we sure we cant flood X25 backlog, using X25 over IP ?
>
> You discovered a _fatal_ flaw in backlog processing, we should close =
all
> holes, not only UDP case. You can be sure many bad guys will inspect =
all
> possibilities to bring down Linux hosts.
>
> If you feel uncomfortable with a small limit, just stick a big one, l=
ike
> 256 packets, and you are 100% sure you wont break a protocol. If this
> limit happens to be too small, we can change it later.
>
> (No need to count bytes, since truesize includes kernel overhead, and
> this overhead depends on 32/64 wide of host and kernel versions)
>
>
>
