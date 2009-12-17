From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Security: Add prctl(PR_{GET,SET}_NETWORK) interface.
Date: Thu, 17 Dec 2009 09:52:34 +0100
Message-ID: <20091217085234.GF9804@basil.fritz.box>
References: <20091216155938.GG15031@basil.fritz.box> <20091217012540.GA2609@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Ulrich Drepper <drepper@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>
To: Michael Stone <michael@laptop.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091217012540.GA2609@heat>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 16, 2009 at 08:25:40PM -0500, Michael Stone wrote:
> Andi Kleen wrote:
>> On Wed, Dec 16, 2009 at 10:32:43AM -0500, Michael Stone wrote:
>>> Daniel Bernstein has observed [1] that security-conscious userland processes
>>> may benefit from the ability to irrevocably remove their ability to create,
>>> bind, connect to, or send messages except in the case of previously
>>> connected sockets or AF_UNIX filesystem sockets. We provide this facility by
>>> implementing support for a new prctl(PR_SET_NETWORK) flag named
>>> PR_NETWORK_OFF.
>>>
>>> This facility is particularly attractive to security platforms like OLPC
>>> Bitfrost [2] and to isolation programs like Rainbow [3] and Plash [4].
>>
>> What would stop them from ptracing someone else running under the same
>> uid who still has the network access? 
>
> Just like in the (revised from last year) rlimits version, there's a hunk in
> the prctl_network semantics patch which disables networking-via-ptrace() like
> so:

Hmm, ok. Missed that. I hope there are not more big holes. Obviously
can't allow to change other executables, but I guess that's ok.

It's still some overlap with network name spaces, but there are also
some not directly mappable semantic differences.

I haven't reviewed the patches in detail btw.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
