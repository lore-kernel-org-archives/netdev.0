From: Edward Cree <ecree@solarflare.com>
Subject: Re: Generic TSO
Date: Mon, 14 Mar 2016 10:26:57 +0000
Message-ID: <56E691F1.2020605@solarflare.com>
References: <20160219191806.15687.37621.stgit@localhost.localdomain>
 <CAMt9YRrOxCmJbrftixdJTXZcySZ_mARqCT6C=4-Nqv_ZJKnTwA@mail.gmail.com>
 <CAEh+42hStEh=5z8KBic0hmEZNti4tjahySjjv7kU3YUes_R4Zg@mail.gmail.com>
 <CALx6S351KYGFFLi08cX=DFCucZtGJLoMJGvFAW1_H-cRXZ0rQg@mail.gmail.com>
 <CAEh+42hEVQOFaFk7BW=wZ-gb9HCfYqbr7Q600gbm1q1Oz+yZcA@mail.gmail.com>
 <CALx6S36EyzjWKi_iK_uAVcCceFnZe3QmLcw7BBejKuB79Uo7PA@mail.gmail.com>
 <56E31A89.9020602@solarflare.com>
 <CALx6S37G5N-3GxXYf8uF9p8QNC+U_d6-Vf+8Jg6bFqEv_FpULg@mail.gmail.com>
 <56E3239B.7080009@solarflare.com>
 <CALx6S37P+gVA_O7vxBjGMxHpY69Cx2aL3E79ptvGkRW4L2x5Ug@mail.gmail.com>
 <56E32966.7090409@solarflare.com>
 <CAKgT0Ud0bj=1Baty7O_8Bi5dEU67-036EeZxLpXjvovANem=6Q@mail.gmail.com>
 <56E338A3.5070909@solarflare.com>
 <CAKgT0UeBx8NepNM2oGkYOnPV2Niy9GPd7RDZdgDMY3EcRMxNmw@mail.gmail.com>
 <CALx6S36wJdFnq=2ZkTfijqro1TM1GTqap=aLQ0+NszgWC6Sznw@mail.gmail.com>
 <CAKgT0UfffHvVZPNbfQseOSTXFXAhjtscdoaVKzYxL1t4rooNEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:59109 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755368AbcCNK1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 06:27:08 -0400
In-Reply-To: <CAKgT0UfffHvVZPNbfQseOSTXFXAhjtscdoaVKzYxL1t4rooNEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/16 05:40, Alexander Duyck wrote:
> Well that is the thing.  Before we can actually start tinkering with
> the outer header we probably need to make sure we set the DF bit and
> that it would be honored on the outer headers for IPv4.  I don't
> believe any of the tunnels are currently doing that so repeating the
> IP ID would be the worst possible scenario until that is resolved
> since VXLAN tunneled frames can be fragmented while TCP frames cannot
> so we really shouldn't be repeating IP IDs for the outer headers.
So how do we progress with that?  I'm presuming it's not as simple as
just patching the tunnel drivers to set DF if the inner packet has it,
as that could break existing setups.  (I've heard that "but they're
already broken anyway" is not usually an acceptable argument.)  Some
sort of configuration option on the tunnel (like we do with udpcsum)?

Fortunately, with the design I'm currently planning on, a tunnel
driver could just set a flag in the SKB to say "unsafe for generic-
TSO", and we'd just send out the first segment normally and fall
back to regular software segmentation.

-Ed
