From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 0/7] net: dsa: mv88e6xxx: support switchdev
 FDB objects
Date: Tue, 11 Aug 2015 12:25:06 -0400 (EDT)
Message-ID: <1065657734.1253359.1439310306115.JavaMail.zimbra@savoirfairelinux.com>
References: <1438839848-505-1-git-send-email-vivien.didelot@savoirfairelinux.com> <20150809.224822.1627697290087246344.davem@davemloft.net> <20150810133924.GA10802@ketchup.touchtunes.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>,
	Guenter Roeck <linux@roeck-us.net>, andrew@lunn.ch,
	Florian Fainelli <f.fainelli@gmail.com>, sfeldma@gmail.com,
	jiri@resnulli.us
To: David <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150810133924.GA10802@ketchup.touchtunes.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Aug 10, 2015, at 9:39 AM, Vivien Didelot vivien.didelot@savoirfairelinux.com wrote:

> Hi David,
> 
> On 15-08-09 22:48:22, David Miller wrote:
>> From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>> Date: Thu,  6 Aug 2015 01:44:01 -0400
>> 
>> > This patchset refactors the DSA and mv88e6xxx code to use the switchdev FDB
>> > objects.
>> 
>> Series applied, thanks.
> 
> I noticed you didn't push the serie yet. I've just sent the v3 which
> includes the switchdev change (ndm_state) mentioned by Scott and the
> reordering of commits to improve bisectability, as suggested by Andrew.
> 
> Please consider the v3 "[PATCH net-next v3 0/8] net: dsa: mv88e6xxx:
> support switchdev FDB objects" instead.

Somehow this message was ignored or seen too late, and v2 got pushed in
the net-next tree.

v2 introduces an uneeded patch to convert switchdev fdb address (1/7);
an is_static member in switchdev that Scott didn't fully agree on (2/7);
and the calls into the driver are removed in 3/7 and added later in the
patchset, making it hard to bisect, as mentioned by Andrew.

v3 fixes all of that, Scott acked the switchdev change and Andrew
reviewed the whole patchset. It is indeed more readable and simpler:

v2: 10 files changed, 317 insertions(+), 197 deletions(-)
v3: 9 files changed, 260 insertions(+), 129 deletions(-)

I can work on fixup patches to restore v3 changes on top of v2, but this
won't fix the bisectability issue.

Instead of fixing individual portions, reverting the merge commit
f1d5ca4: "Merge branch 'mv88e6xxx-switchdev-fdb'" would undo all the v2
series at once, then v3 can be merged on top of it.

Can you consider this as an option?

Thanks,
-v
