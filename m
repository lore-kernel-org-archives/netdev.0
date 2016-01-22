From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v2] wl1251: add sysfs interface for bluetooth coexistence mode configuration
Date: Fri, 22 Jan 2016 13:55:44 +0200
Message-ID: <87wpr1x1z3.fsf@kamboji.qca.qualcomm.com>
References: <1451130310-16666-1-git-send-email-pali.rohar@gmail.com>
	<5696D08F.9030906@broadcom.com> <20160114091654.GA15380@amd>
	<20160121085331.GO7192@pali> <87d1svyrfl.fsf@kamboji.qca.qualcomm.com>
	<20160121135110.GH7192@pali> <871t9byotq.fsf@kamboji.qca.qualcomm.com>
	<20160122092935.GL7192@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Machek <pavel@ucw.cz>, Arend van Spriel <arend@broadcom.com>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Gnedt <david.gnedt@davizone.at>
To: Pali =?utf-8?Q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160122092935.GL7192@pali> ("Pali =?utf-8?Q?Roh=C3=A1r=22's?=
 message of "Fri, 22
	Jan 2016 10:29:35 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pali Roh=C3=A1r <pali.rohar@gmail.com> writes:

>> >> > Right, bt-coex is not for debugging purpose, but for normal usa=
ge, when
>> >> > user want to use together bluetooth and wifi or just one of tho=
se.
>> >>=20
>> >> I think most of other drivers have a debugfs interface for btcoex=
, I
>> >> guess mostly for testing purposes. But this really should be adde=
d to
>> >> cfg80211.
>> >
>> > All other TI wireless drivers have "bt_coex_state" sysfs node.
>>=20
>> Then that's a mistake, they shouldn't have that.
>
> But it is there, wl1251 is also TI wireless driver and for last two
> years there is no interface to deal with this problem...
>
> So as other drivers do, I'm proposing solution which fix bt coex also
> for wl1251 driver need on Nokia N900.

Even if the wlcore sysfs interface fell through the cracks it's no
excuse to add more private interfaces to wireless drivers. We have
cfg80211 and all generic interfaces, like btcoex control, should go
through that subsystem. That way all drivers can share a common
interface and everyone are happy.

What I suggest is that you add this yourself to cfg80211 and mac80211.
It's not that hard and I think you could use NL80211_CMD_SET_POWER_SAVE
as an example.

--=20
Kalle Valo
