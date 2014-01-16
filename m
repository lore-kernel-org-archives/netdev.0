From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 1/2] random32: add prandom_u32_lt_N and convert
 "misuses" of reciprocal_divide
Date: Wed, 15 Jan 2014 16:29:32 -0800
Message-ID: <1389832172.14001.41.camel@joe-AO722>
References: <1389828228-30312-1-git-send-email-dborkman@redhat.com>
	 <1389828228-30312-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389828228-30312-2-git-send-email-dborkman@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-01-16 at 00:23 +0100, Daniel Borkmann wrote:
> Many functions have open coded a function that return a random
> number in range [0,N-1]. Also, only because we have a function
> that is named reciprocal_divide(), it has not much to do with
> the pupose where it is being used when a previous reciprocal_value()
> has not been obtained.

prandom_u32_lt_N?

I do not like the camelcase name and thought the
prandom_u32_max was better.

How about using

u32 prandom_u32_max(u32 max)
{
	return (u32)(((u64)prandom_u32() * max) >> 32);
}

u32 prandom_u32_range(u32 a, u32 b)
{
	if (b < a)
		swap(a, b);

	return a + (u32)(((u64)prandom_u32() * (b - a)) >> 32);
}
