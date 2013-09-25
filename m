From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Re: [PATCH] Allow userspace code to use flag IFA_F_SECONDARY to
 specify an ip address to be primary or secondary ip on an interface
Date: Wed, 25 Sep 2013 10:30:22 -0700
Message-ID: <CAK3+h2wYw92KR-Bzxesb5hNW2ua4GmVLeywJ__uPyqMW-+p8pA@mail.gmail.com>
References: <1380046281-6012-1-git-send-email-vincent.mc.li@gmail.com>
	<alpine.LFD.2.00.1309242255350.1875@ja.ssi.bg>
	<CAK3+h2y8eAKFC7BbnDwfZLzTw=t-G9qWSqznp4ggwDy7R_O6Ag@mail.gmail.com>
	<alpine.LFD.2.00.1309250925240.1971@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Julian Anastasov <ja@ssi.bg>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1309250925240.1971@ja.ssi.bg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think it is good idea to add these preferences flags and sorted
them, but my code knowledge is limited to implement it  as I am still
learning, I can help testing :)

On Wed, Sep 25, 2013 at 12:08 AM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         Hello,
>
> On Tue, 24 Sep 2013, Vincent Li wrote:
>
>> Thanks Julian for the comments, I imagined it would not be so simple
>> as it changed old behavior with ip binary and some actions in
>> __inet_del_ifa() that I am not fully aware of. my intention is to
>> preserve the old behavior and extend the flexibility, I am unable to
>> come up with a good patch to achieve the intended behavior.
>
> ...
>
>> if someone can point me to the right patch directions or coming up
>> with better patches, it is very much appreciated.
>
>         My first idea was to use NLM_F_APPEND to implement
> 'ip addr prepend' and 'ip addr append' but the default
> operation is 'append' without providing NLM_F_APPEND, so it
> does not work.
>
>         Another idea is to add new attribute IFA_PREFERENCE in
> include/uapi/linux/if_addr.h just before __IFA_MAX, integer,
> 3 of the values are known. A preference for the used scope.
>
> /* Add as last, default */
> IFA_PREFERENCE_APPEND = 0,
>
> /* Add as last primary, before any present primary in subnet */
> IFA_PREFERENCE_PRIMARY = 128,
>
> /* First for scope */
> IFA_PREFERENCE_FIRST = 255,
>
>         We should keep it in ifa as priority, for
> sorting purposes. It can be 4-byte value, if user wants
> to copy user-defined order into preference.
>
>         Sorting order should be:
>
> - all primaries sorted by decreasing scope, decreasing
> priority and adding order
>
> - then all secondaries (IFA_F_SECONDARY) sorted by decreasing
> priority and adding order
>
>         Usage:
>
> ip addr add ... pref[erence] type_or_priority
>
> # Add floating IP (append at priority 128)
> # The primary mode is not guaranteed if another address from
> # the same subnet is already using the same or higher priority.
> ip addr add ... pref primary
> # More preferred primary
> ip addr add ... pref 129
>
> # Add first IP for scope
> ip addr add ... pref first
>
>         The scope has similar 'sorting' property but not
> for IPs in same subnet and it would be difficult to use
> it for global routes.
>
>         Thoughts?
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
