From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC 4/9] snet: introduce snet_core.c and snet.h
Date: Sat, 23 Jan 2010 03:07:36 +0100
Message-ID: <m21vhhefpz.fsf@ssh.synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
	<1262437456-24476-5-git-send-email-sam@synack.fr>
	<4B41FE9D.2070708@trash.net> <m2y6kbm2xw.fsf@ssh.synack.fr>
	<20100106195830.GA17510@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	linux-security-module@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20100106195830.GA17510@ioremap.net> (Evgeniy Polyakov's message
	of "Wed, 6 Jan 2010 22:58:30 +0300")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm sorry for the delay I missed this one.

Evgeniy Polyakov <zbr@ioremap.net> writes:
> On Wed, Jan 06, 2010 at 08:46:35PM +0100, Samir Bellabes (sam@synack.fr) wrote:
>> Patrick McHardy <kaber@trash.net> writes:
>> 
>> >> +struct snet_event {
>> >> +	enum snet_syscall syscall;
>> >> +	u8 protocol;
>> >> +} __attribute__ ((packed));
>> >
>> > Does this really need to be packed? You're using it in a
>> > struct snet_event_entry, which is padded anyways.
>> 
>> I think that that members needs to be aligned, because this struct is
>> used for the jhash() computation.
>> when testing on x86_64, I discovered that jhash value wasn't the same,
>> for a same struct snet_event. Then I thougth about misaligned data, and
>> possible 'hole' between syscall and protocol.
>
> Without padding it will eat additional bytes after 'protocol' field,
> since enum is 32-bit long.

thanks for this help.


>> anyway, I patched the code to use jhash_2words() or jhash_1word().
>> here is a patch, which apply on top of initial serie
>
> What's the purpose of hashing verdict_id?

indeed, there is no specific purpose, I will fix this now.

thanks, and again sorry for the delay.
sam
