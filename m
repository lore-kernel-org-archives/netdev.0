From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC v3 00/10] snet: Security for NETwork syscalls
Date: Tue, 03 May 2011 19:15:10 +0200
Message-ID: <874o5b3dup.fsf@synack.fr>
References: <1304432663-1575-1-git-send-email-sam@synack.fr>
	<4DC0330C.60208@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Patrick McHardy <kaber@trash.net>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Grzegorz Nosek <root@localdomain.pl>
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4DC0330C.60208@schaufler-ca.com> (Casey Schaufler's message of
	"Tue, 03 May 2011 09:53:32 -0700")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Casey Schaufler <casey@schaufler-ca.com> writes:

> On 5/3/2011 7:24 AM, Samir Bellabes wrote:
>> Hello lsm and netdev people,
>> This set of patches is the version 3 of snet, which I would like to submit as a
>> RFC.
>>
>> snet is a linux security module. It provides a mecanism defering syscall
>> security hooks and decision (verdict) to userspace.
>
> As you have submitted this as a Request For Comments I will make one.
>
> I first saw this approach in 1987, on Unix, from a company called
> SecureWare (long completely assimilated into HP). The potential for
> deadlock, where the system prevents the decision making application
> from accessing the information it needs to grant itself access is
> great. The performance impact of making security checks in user
> space is appalling. The exposure for attack, especially regarding
> denial of service, is enormous. I do not recommend this approach.
>
> There are cases where user space access control assistance could
> be appropriate, in particular controls based on the data involved.
> Even those controls must be very carefully crafted to avoid
> impacting the correct function of the system in the unhappily
> likely event of the access control enforcing applications being
> unavailable or incapable of keeping up with demand.
>

As everything may be exposed to denial of service attack..
I have some thoughts. snet is not a tool for securing the kernel code,
there is only one way to do so, it's to fix bug and to add code feature
to protect memory (cf grsecurity). snet is a tool to manage the
behaviour of users and applications, regarding network connections. 

the risk of deadlock is uneffective, as every sleeps occurs in process
context, so application can sleep without trouble.
there are 2 ways to go out of sleep :
 - receiving the verdict
 - timeouting

so deadlock are more "latency".
You win a admin tool, you loose some latency. I'm ok with that, as this
feature as its own public.

and of course, I'm not pretending to add a new idea. I'm sure some
mecanism like this already exist before 1987. I'm just the man who put
the code in order to be discuss on the lists, which was never been done
so far. 

there are some request from public distro:
http://brainstorm.ubuntu.com/idea/23333/
