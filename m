From: Eyal Perry <eyalpe@dev.mellanox.co.il>
Subject: Re: BW regression after "tcp: refine TSO autosizing"
Date: Tue, 13 Jan 2015 23:41:15 +0200
Message-ID: <54B590FB.5040805@dev.mellanox.co.il>
References: <54B54C72.8060705@dev.mellanox.co.il>	<1421175434.4099.21.camel@edumazet-glaptop2.roam.corp.google.com> <CAJ3xEMibMzJH-AB7pBnO9qBL4McTdsajqHzxXkadnTf1khNdxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Amir Ancel <amira@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:58640 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176AbbAMVlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 16:41:20 -0500
Received: by mail-wg0-f45.google.com with SMTP id y19so5504185wgg.4
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 13:41:19 -0800 (PST)
In-Reply-To: <CAJ3xEMibMzJH-AB7pBnO9qBL4McTdsajqHzxXkadnTf1khNdxA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/13/2015 22:21 PM, Or Gerlitz wrote:
> On Tue, Jan 13, 2015 at 8:57 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Tue, 2015-01-13 at 18:48 +0200, Eyal Perry wrote:
>>> Hello Eric,
>>> Lately we've observed performance degradation in BW of about 30-40% (depends on
>>> the setup we use).
>>> I've bisected the issue down to the this commit: 605ad7f1 ("tcp: refine TSO
>>> autosizing")
>>>
>>> For instance, I was running the following test:
>>> 1. Bounding net device' irqs to core 0 for both client and server side
>>> 2. Running netperf with 64K massage size (used the following command)
>>> $ netperf -H remote -T 1,1 -l 100 -t TCP_STREAM -- -k THROUGHPUT -M 65536 -m 65536
>>>
>>> I ran the test on upstream net-next including your patch and than reverted it
>>> and these are the results I got was improvement from 14.6Gbps to 22.1Gbps.
>>>
>>> an additional difference I've noticed when inspecting the ethtool statics,
>>> number of xmit_more packets increased from 4 to 160 with the reverted kernel.
>>>
>>> We are investigating this issue, do you have a hint?
>> Which driver are you using for this test ?
> AFAIK, mlx4
Oops, forgot to mention.
mlx4 indeed.
