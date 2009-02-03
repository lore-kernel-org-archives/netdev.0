From: Pekka Savola <pekkas@netcore.fi>
Subject: net.ipv6.conf.INT.accept_ra_rt_info_max_plen defaults to 0
Date: Tue, 3 Feb 2009 06:38:49 +0200 (EET)
Message-ID: <alpine.LRH.2.00.0902030632240.7583@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Teran McKinney <sega01@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:34744 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751358AbZBCEvk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2009 23:51:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

As reported and discussed below and in 
<http://www.mail-archive.com/debian-ipv6@lists.debian.org/msg03753.html>, 
to accept "route information option" on Linux, you have to manually 
change accept_ra_rt_info_max_plen sysctl value.  Other implementations 
that I know of accept this by default.

Is it intentional that Route Information options are ignored by 
default?

I suspect not -- if so, the default value should be (IMHO) 64 or if 
that's disagreeable, 48.

Even if this is intentional, I think the intentions should be 
revisited.

---------- Forwarded message ----------
Date: Mon, 2 Feb 2009 17:24:00 +0000
From: Teran McKinney <sega01@gmail.com>
Reply-To: radvd Development Discussion <radvd-devel-l@litech.org>
To: radvd Development Discussion <radvd-devel-l@litech.org>
Subject: Re: [radvd-devel-l] Linux and specific routes

Hey,

I have finally obtained my answer. I ended up reading RFC 4191,
glancing at RFC 2461, and looking at Linux's source code, but found
what I was looking for. It turns out that "route information option"
is more precise than "specific routes", so I googled for it and found
that Linux supports it just fine; all you have to do is set
accept_ra_rt_info_max_plen to the maximum prefix length you want to
accept. <http://www.mail-archive.com/debian-ipv6@lists.debian.org/msg03753.html>
is very helpful.

Cheers and thanks,
Teran

On Sun, Dec 21, 2008 at 18:27, Arnaud Ebalard <arnaud.ebalard@eads.net> wrote:
>
> "Teran McKinney" <sega01@gmail.com> writes:
>
>> I added the patch, but it does not seem to affect specific routes. I
>> was only using one router at first, but tried with an additional
>> router and had no luck. Specific routes just aren't been added :-(.
>> This configuration seems to work fine if manually added, so I'm not
>> sure what is wrong.
>
> If you compiled the kernel with the support and enabled the /proc
> entries to activate the feature, then it looks like a bug. Maybe you
> could drop a mail to the author of the patch.
>
> Cheers,
>
> a+
>
> --
> radvd-devel-l mailing list  :  radvd-devel-l@litech.org
> http://lists.litech.org/listinfo/radvd-devel-l
>

-- 
radvd-devel-l mailing list  :  radvd-devel-l@litech.org
http://lists.litech.org/listinfo/radvd-devel-l
