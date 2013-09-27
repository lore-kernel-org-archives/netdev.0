From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Allow userspace code to use flag IFA_F_SECONDARY to
 specify an ip address to be primary or secondary ip on an interface
Date: Fri, 27 Sep 2013 22:26:29 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1309272221210.1725@ja.ssi.bg>
References: <1380046281-6012-1-git-send-email-vincent.mc.li@gmail.com> <alpine.LFD.2.00.1309242255350.1875@ja.ssi.bg> <CAK3+h2y8eAKFC7BbnDwfZLzTw=t-G9qWSqznp4ggwDy7R_O6Ag@mail.gmail.com> <alpine.LFD.2.00.1309250925240.1971@ja.ssi.bg>
 <CAK3+h2wYw92KR-Bzxesb5hNW2ua4GmVLeywJ__uPyqMW-+p8pA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Vincent Li <vincent.mc.li@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK3+h2wYw92KR-Bzxesb5hNW2ua4GmVLeywJ__uPyqMW-+p8pA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 25 Sep 2013, Vincent Li wrote:

> I think it is good idea to add these preferences flags and sorted
> them, but my code knowledge is limited to implement it  as I am still
> learning, I can help testing :)

	I can try it, if such idea looks good enough to
others.

> On Wed, Sep 25, 2013 at 12:08 AM, Julian Anastasov <ja@ssi.bg> wrote:
>
> >         My first idea was to use NLM_F_APPEND to implement
> > 'ip addr prepend' and 'ip addr append' but the default
> > operation is 'append' without providing NLM_F_APPEND, so it
> > does not work.
> >
> >         Another idea is to add new attribute IFA_PREFERENCE in
> > include/uapi/linux/if_addr.h just before __IFA_MAX, integer,
> > 3 of the values are known. A preference for the used scope.
> >
> > /* Add as last, default */
> > IFA_PREFERENCE_APPEND = 0,
> >
> > /* Add as last primary, before any present primary in subnet */
> > IFA_PREFERENCE_PRIMARY = 128,
> >
> > /* First for scope */
> > IFA_PREFERENCE_FIRST = 255,
> >
> >         We should keep it in ifa as priority, for
> > sorting purposes. It can be 4-byte value, if user wants
> > to copy user-defined order into preference.
> >
> >         Sorting order should be:
> >
> > - all primaries sorted by decreasing scope, decreasing
> > priority and adding order
> >
> > - then all secondaries (IFA_F_SECONDARY) sorted by decreasing
> > priority and adding order
> >
> >         Usage:
> >
> > ip addr add ... pref[erence] type_or_priority
> >
> > # Add floating IP (append at priority 128)
> > # The primary mode is not guaranteed if another address from
> > # the same subnet is already using the same or higher priority.
> > ip addr add ... pref primary
> > # More preferred primary
> > ip addr add ... pref 129
> >
> > # Add first IP for scope
> > ip addr add ... pref first
> >
> >         The scope has similar 'sorting' property but not
> > for IPs in same subnet and it would be difficult to use
> > it for global routes.
> >
> >         Thoughts?

Regards

--
Julian Anastasov <ja@ssi.bg>
