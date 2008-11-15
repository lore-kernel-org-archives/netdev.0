From: Willy Tarreau <w@1wt.eu>
Subject: Re: tcp_tw_recycle broken?
Date: Sat, 15 Nov 2008 16:52:28 +0100
Message-ID: <20081115155228.GZ24654@1wt.eu>
References: <f9be06770811142037v794cf4f8w7a82ab45c0f3820c@mail.gmail.com> <20081115055748.GY24654@1wt.eu> <f9be06770811142329x7d6dcb89vd573962970d503b3@mail.gmail.com> <874p2916hb.fsf@basil.nowhere.org> <f9be06770811150747l574badc1l8d509baae4f81ac5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Karl Pickett <karl.pickett@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1245 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751345AbYKOPwd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2008 10:52:33 -0500
Content-Disposition: inline
In-Reply-To: <f9be06770811150747l574badc1l8d509baae4f81ac5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 15, 2008 at 10:47:10AM -0500, Karl Pickett wrote:
> On Sat, Nov 15, 2008 at 8:09 AM, Andi Kleen <andi@firstfloor.org> wrote:
> > "Karl Pickett" <karl.pickett@gmail.com> writes:
> >>
> >> May I just confirm.. is tcp_tw_reuse NOT dependent on receiving timestamps?
> >
> > The big problem is that both are incompatible with NAT. So if you
> > ever talk to any NATed clients don't use it.
> >
> > -Andi
> >
> > --
> > ak@linux.intel.com
> >
> 
> 
> Hmph.  Running the test again - after getting a little sleep -
> timestamps do indeed determine if tw_reuse/recyle work.  I must not
> have let all the tw buckets expire before changing my timestamp
> settings last night.
> 
> Since
> A. I don't want to rely on arbitrary web servers having timestamps
> B. People say it breaks NAT for clients, and the settings are global only,
> 
> I will just set TCP_TIMEWAIT_LEN to 10 seconds and call it a day.

you should increase it a bit. I've encountered occasional issues at 15s,
but none at 20s.

> Sure would be nice if it was a tunable, so only the most heavily
> loaded customers could set it...

Indeed. other OSes (eg Solaris) ship with standard values and let us adjust
them.

Willy

