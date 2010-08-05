From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: GIT: net-*2.6 rebased...
Date: Thu, 05 Aug 2010 01:46:37 -0700 (PDT)
Message-ID: <20100805.014637.13722703.davem@davemloft.net>
References: <20100804.162141.15218463.davem@davemloft.net>
	<4C5A6EFE.7040703@arndnet.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org
To: arnd-BCMAnToX5e2ELgA04lAiVw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4C5A6EFE.7040703-BCMAnToX5e2ELgA04lAiVw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Arnd Hannemann <arnd-BCMAnToX5e2ELgA04lAiVw@public.gmane.org>
Date: Thu, 05 Aug 2010 09:57:50 +0200

> if I try to fetch from net-next-2.6, I get:
> fatal: The remote end hung up unexpectedly
> 
> if I try to clone net-2.6:
> (e.g. git clone git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
> 
> I get lots of errors reading the tags "does not point to a valid object!" and then:
> remote: error: Could not read 3cfc2c42c1cbc8e238bb9c0612c0df4565e3a8b4
> remote: fatal: Failed to traverse parents of commit 7aaaaa1e44b2a4047dfe05f304a5090eb995cf44
> remote: aborting due to possible repository corruption on the remote side.
> fatal: early EOF
> fatal: index-pack failed

Hmmm, since I can I tried an ssh based clone and it works.

But indeed if I try to use the git:// URL it fails.

Oh I see, the alternates files in those repos are completely broken.
They have:

	/home/davem/git/../torvalds/linux-2.6.git/objects

/home/davem/git is a symlink to /pub/scm/linux/kernel/git/davem
so if I login and "cd git" then:

	git clone --shared --bare ../torvalds/linux-2.6.git net-next-2.6.git

which is how I always create my trees, we get that unusable 'alternates'
path above.

The ".." works when my GIT directory is the working directory, but
not as part of the symlink include path to get there.

I fixed the alternates file but it will take some time for the fix
to propagate from master.kernel.org

Let me know if it doesn't work even after an hour or so.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
