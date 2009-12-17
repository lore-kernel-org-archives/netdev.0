From: Michael Stone <michael@laptop.org>
Subject: Re: [PATCH] Security: Add prctl(PR_{GET,SET}_NETWORK) interface.
Date: Wed, 16 Dec 2009 20:25:40 -0500
Message-ID: <20091217012540.GA2609@heat>
References: <20091216155938.GG15031@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Michael Stone <michael@laptop.org>,
	Ulrich Drepper <drepper@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
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
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091216155938.GG15031@basil.fritz.box>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> On Wed, Dec 16, 2009 at 10:32:43AM -0500, Michael Stone wrote:
>> Daniel Bernstein has observed [1] that security-conscious userland processes
>> may benefit from the ability to irrevocably remove their ability to create,
>> bind, connect to, or send messages except in the case of previously
>> connected sockets or AF_UNIX filesystem sockets. We provide this facility by
>> implementing support for a new prctl(PR_SET_NETWORK) flag named
>> PR_NETWORK_OFF.
>> 
>> This facility is particularly attractive to security platforms like OLPC
>> Bitfrost [2] and to isolation programs like Rainbow [3] and Plash [4].
> 
> What would stop them from ptracing someone else running under the same
> uid who still has the network access? 

Just like in the (revised from last year) rlimits version, there's a hunk in
the prctl_network semantics patch which disables networking-via-ptrace() like
so:

diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 23bd09c..5b38db0 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -151,6 +151,8 @@ int __ptrace_may_access(struct task_struct *task, unsigned int mode)
                dumpable = get_dumpable(task->mm);
        if (!dumpable && !capable(CAP_SYS_PTRACE))
                return -EPERM;
+       if (current->network)
+               return -EPERM;

        return security_ptrace_access_check(task, mode);
  }

More questions?

Regards, and thanks for your interest,

Michael
