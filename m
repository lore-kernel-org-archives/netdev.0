From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: [PATCH 6/7] mlx4_en: Adding rxhash support
Date: Tue, 18 Oct 2011 11:49:19 -0700
Message-ID: <CAEuXFEwzoC-L7Agr3Ssq9M-QN2w+t=rxjVvt9oJwQ2pQw7To8w@mail.gmail.com>
References: <4E9C8D8B.90606@mellanox.co.il>
	<1318902525.2571.24.camel@edumazet-laptop>
	<953B660C027164448AE903364AC447D2235EEB65@MTLDAG01.mtl.com>
	<1318926870.2657.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<953B660C027164448AE903364AC447D2235EEC80@MTLDAG01.mtl.com>
	<20111018083606.6367ff50@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:54194 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797Ab1JRStU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 14:49:20 -0400
Received: by bkbzt19 with SMTP id zt19so1115001bkb.19
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 11:49:19 -0700 (PDT)
In-Reply-To: <20111018083606.6367ff50@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 18, 2011 at 8:36 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Tue, 18 Oct 2011 08:59:44 +0000
> Yevgeny Petrilin <yevgenyp@mellanox.co.il> wrote:
>> There is no gain in random values,
>> I'll make the change to have static value for RSS function.
>>
>> We might consider how to ensure consistency across the different dri=
vers in this aspect.
>
> The key should be part of the network device core. Almost all hardwar=
e just
> implements the Microsoft standard, and if all drivers used same key t=
hey should
> come up with the same hash.
>
> Although using the same key all the time makes testing easier.
> The risk of using the same key is that it makes it easier for an atta=
cker to
> create a set of addresses that all map to the same CPU which would ma=
ke a DoS
> attack work better. =A0Therefore the key should be randomly generated=
 at boot time.

Stephen, I respectfully disagree with your position here.  The risk of
using the same key is that a malicious user could target a particular
queue with a DoS attack, but how is that different than any single
queue device?  NAPI protects a single queue against (a network
interrupt based) DoS.  I do not think we should be generating a random
key at boot time, and because of the way NAPI mitigates load, we are
okay.  The gain from from the far simpler setup (and reproducability)
outweighs the risk until someone can show damage due to this
theoretical DoS attack.
