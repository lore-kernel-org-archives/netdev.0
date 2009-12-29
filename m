From: Michael Stone <michael@laptop.org>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Tue, 29 Dec 2009 11:06:20 -0500
Message-ID: <20091229160620.GB14668@heat>
References: <m1y6km11lj.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>, Pavel Machek <pavel@ucw.cz>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Michael
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1y6km11lj.fsf@fess.ebiederm.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Biederman writes:
> Serge,
>
> Michael Stone <michael@laptop.org> writes:
>> I think that Pavel's point, at its strongest and most general, could be
>> rephrased as:
>>
>>   "Adding *any* interesting isolation facility to the kernel breaks backwards
>>    compatibility for *some* program [in a way that violates security goals]."
>
>*some* privileged program.

Your amendment is a good one; it makes the statement better reflect your and
Pavel's concern. Thanks.

>> The reason is the one that I identified in my previous note:
>>
>>   "The purpose of isolation facilities is to create membranes inside which
>>    grievous security faults are converted into availability faults."
>>
>> The question then is simply:
>>
>>   "How do we want to deal with the compatibility-breaking changes created by
>>    introducing new isolation facilities?"

> You have a very peculiar taxonomy of the suggestions,
> that fails to capture the concerns.

Do you agree with my assessment that this is fundamentally a
backwards-compatibility problem with security consequences?

> I strongly recommend working out a way to disable
> setuid exec.  Ideally we would use capabilities to
> achieve this.  
> 
> ...
> 
> I can see one of two possible reasons you are avoiding the
> suggestion to disable setuid root...

Heard and understood. I'll start thinking about how to do it (and about what
the consequences might be). However, those aren't my reasons for wariness.

My reasons have to do with history, preparation, and logic: 

   1. I first began playing with disablenetwork about two years ago and I missed
      both the need to restrict ptrace and the fact that the interaction with
      privileged executables would be a problem for other people.

   2. With disablenetwork, I was already building on clear (if slightly
      incomplete) design by djb. We have none of that prep work here.

   3. We have definite reasons, laid out by my argument above about the general
      compatibility cost of isolation facilities, to suspect that disablesuid
      in any form will break at least one other interesting use case. I don't
      know what that use case is yet but I'm fairly sure that it exists.

> The problem with the disable_network semantics you want
> is that they allow you to perform a denial of service attack
> on privileged users. An unprivileged DOS attack is unsuitable
> for a general purpose feature in a general purpose kernel.

Then where did rlimits come from? rlimits *can* DoS privileged processes and
people are pretty much okay with the idea. People who are concerned can raise
the rlimits in their privileged processes and get on with life.

Second, as you point out, I am willing to audit and to modify my setuid
executables *in exchange* for having a kernel that changes in useful ways.
Obviously, not everyone is willing to pay this upkeep.

At any rate, I hope all this helps make my position clearer. I'll think more
about your suggestions.

Regards,

Michael
