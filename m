From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [Drbd-dev] [PATCH net-next v3] block/drbd: align properly u64 in
 nl messages
Date: Tue, 10 May 2016 12:06:40 +0200
Message-ID: <5731B2B0.3000400@6wind.com>
References: <20160503100644.GE16459@soda.linbit>
 <1462786820-15519-1-git-send-email-nicolas.dichtel@6wind.com>
 <20160509131547.GX16459@soda.linbit> <5731A561.6090509@6wind.com>
 <20160510094023.GC16459@soda.linbit>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: davem@davemloft.net, netdev@vger.kernel.org,
	philipp.reisner@linbit.com, drbd-dev@lists.linbit.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160510094023.GC16459@soda.linbit>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 10/05/2016 11:40, Lars Ellenberg a =E9crit :
> On Tue, May 10, 2016 at 11:09:53AM +0200, Nicolas Dichtel wrote:
>> Le 09/05/2016 15:15, Lars Ellenberg a =E9crit :
>>> On Mon, May 09, 2016 at 11:40:20AM +0200, Nicolas Dichtel wrote:
>> [snip]
>>>> Maybe prefixing genl_magic_func.h and genl_magic_struct.h by 'drbd=
_'
>>>> could be interesting so that new module won't use it. What is your
>>>> opinion?
>>>
>>> This was supposed to not be DRBD specific.  But it might even still
>>> need some massaging before it was truly generic. And obviously,
>>> it does not meet the taste of genetlink folks, to say the least :(
>> Yes, this file is not generic and netlink APIs are never defined lik=
e this.
>> These tons of macro complexifies the code too much. It's overenginee=
ring for
>> what purpose?
>=20
> If we introduce a new config option,
> we have to add it to the config scanner (one line),
> define min, max, default and scale (four short defines),
> and add it to the netlink definition here (one line).
> Done, rest of the code is generated,
> both on the kernel side,
> and on the drbd-utils side used to talk to the kernel.
> We found that to be very convenient.
Ok.

>=20
>> Small examples:
>>  - the drbd netlink API is not exported via uapi (I wonder how apps =
using this
>>    API get it)
>=20
> There used to be a time where there was no "uapi".
> (I wonder how apps ever worked back then).
At that time, include/linux/ was exported ;-)

>=20
>>  - v2 of the patch is nacked because adding a new attribute may brea=
k existing
>=20
> No.
>=20
> But because the "new" attributes you chose have not been new,
> but already used (though not yet merged back into mainline yet).
> (Which you did not realize, and had no obvious way of knowing.
>  Could have been fixed.).
Ok.

>=20
> And because your patch introduced useless new members to the structs.
> (Could also have been fixed).
>=20
> And because I did not see any use defining that many new "padding att=
ributes"
> for no reason, where the obvious (to me) choice was to use 0, and you
> did not even try to explain why that would have been a bad choice.
Because some nl APIs were wrongly use 0 as a valid attribute we make th=
e choice
of always adding a new attribute for padding to be sure to not break ex=
isting API.
And yes, in drdb it does not seem to be the case.

> Is this going somewhere?
I'm just trying to understand things.


Regards,
Nicolas
