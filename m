From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: PSCHED_TDIFF_SAFE bug introduced in 2.4.19-pre5
Date: Sun, 12 May 2002 20:35:47 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200205121635.UAA01437@mops.inr.ac.ru>
References: <Pine.LNX.4.44.0205051726480.12674-100000@luxik.cdi.cz>
Mime-Version: 1.0
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: devik@cdi.cz (Martin Devera)
In-Reply-To: <Pine.LNX.4.44.0205051726480.12674-100000@luxik.cdi.cz> from "Martin Devera" at May 5, 2 05:41:19 pm
List-Id: netdev.vger.kernel.org

Hello!

> I think you are responsible for the change.

Yes.


> even if tv1<tv2 which can be true when time wraps (which is true
> at least with PSCHED_TIME_SOURCE == JIFFIES)

No, psched_time_t cannot wrap for our life.


> one HTB user switched to 2.4.19-pre7.

I think this discipline simply calls the function with tv1 < tv2.
In this case the function is supposed to return a negative number
and used to do this. Actually, invalid behaviour with unsigned bound
was one of bugs fixed.


> Here the return value will be always positive and < bound.

It must not be positive when tv1 < tv2, psched_diff_t is signed.
Well, taking into account that it is not used in current kernel
with tv1 < tv2, it can be changed to return 0, but surely not to "bound".

I did not see HTB qdisc, but plain logic tells me that otherwise
you will see a delay ~bound, when an immediate send is expected instead.

Alexey
