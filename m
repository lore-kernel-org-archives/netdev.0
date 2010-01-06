From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [RFC 4/9] snet: introduce snet_core.c and snet.h
Date: Wed, 6 Jan 2010 22:58:30 +0300
Message-ID: <20100106195830.GA17510@ioremap.net>
References: <1262437456-24476-1-git-send-email-sam@synack.fr> <1262437456-24476-5-git-send-email-sam@synack.fr> <4B41FE9D.2070708@trash.net> <m2y6kbm2xw.fsf@ssh.synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	linux-security-module@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Samir Bellabes <sam@synack.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from corega.com.ru ([195.178.208.66]:49716 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755992Ab0AFT6h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2010 14:58:37 -0500
Content-Disposition: inline
In-Reply-To: <m2y6kbm2xw.fsf@ssh.synack.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 06, 2010 at 08:46:35PM +0100, Samir Bellabes (sam@synack.fr) wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
> >> +struct snet_event {
> >> +	enum snet_syscall syscall;
> >> +	u8 protocol;
> >> +} __attribute__ ((packed));
> >
> > Does this really need to be packed? You're using it in a
> > struct snet_event_entry, which is padded anyways.
> 
> I think that that members needs to be aligned, because this struct is
> used for the jhash() computation.
> when testing on x86_64, I discovered that jhash value wasn't the same,
> for a same struct snet_event. Then I thougth about misaligned data, and
> possible 'hole' between syscall and protocol.

Without padding it will eat additional bytes after 'protocol' field,
since enum is 32-bit long.

> anyway, I patched the code to use jhash_2words() or jhash_1word().
> here is a patch, which apply on top of initial serie

What's the purpose of hashing verdict_id?

-- 
	Evgeniy Polyakov
