From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [kernel-hardening] [PATCH 0/2] capability controlled user-namespaces
Date: Mon, 2 Oct 2017 11:12:09 -0700
Message-ID: <CAF2d9jjc6z_cO7co_C7L7xPujqA2npa2nXpUHZbE-Le6BSGFNg@mail.gmail.com>
References: <20170929230952.29673-1-mahesh@bandewar.net> <20171002171410.GA19611@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Mahesh Bandewar <mahesh-bmGAjcP2qsnk1uMJSBkQmQ@public.gmane.org>,
        LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Kernel-hardening <kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171002171410.GA19611-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 2, 2017 at 10:14 AM, Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
> Quoting Mahesh Bandewar (mahesh-bmGAjcP2qsnk1uMJSBkQmQ@public.gmane.org):
>> From: Mahesh Bandewar <maheshb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>>
>> [Same as the previous RFC series sent on 9/21]
>>
>> TL;DR version
>> -------------
>> Creating a sandbox environment with namespaces is challenging
>> considering what these sandboxed processes can engage into. e.g.
>> CVE-2017-6074, CVE-2017-7184, CVE-2017-7308 etc. just to name few.
>> Current form of user-namespaces, however, if changed a bit can allow
>> us to create a sandbox environment without locking down user-
>> namespaces.
>>
>> Detailed version
>> ----------------
>
> Hi,
>
> still struggling with how I feel about the idea in general.
>
> So is the intent mainly that if/when there comes an 0-day which allows
> users with CAP_NET_ADMIN in any namespace to gain privilege on the host,
> then this can be used as a stop-gap measure until there is a proper fix?
>
Thank for looking at this Serge.

Yes, but at the same time it's not just limited to NET_ADMIN but could
be any of the current capabilities.

> Otherwise, do you have any guidance for how people should use this?
>
> IMO it should be heavily discouraged to use this tool as a regular
> day to day configuration, as I'm not sure there is any "educated"
> decision to be made, even by those who are in the know, about what
> to put in this set.
>
I think that really depends on the environment. e.g. in certain
sandboxes third-part / semi-trusted workload is executed where network
resource is not used. In that environment I can easily take off
NET_ADMIN and NET_RAW without affecting anything there. At the same
time I wont have to worry about 0-day related to these two
capabilities. I would say the Admins at these places are in the best
place to decide what they can take-off safely and what they cannot.
Even if they decide not to take-off anything, having a tool at hand to
gain control is important when the next 0-day strikes us that can be
exploited using any of the currently used capabilities.

However, you are absolutely right in terms of using it as a stop-gap
measure to protect environment until it's fixed and the capability in
question can not be safely taken off permanently without hampering
operations.

thanks,
--mahesh..

[...]
