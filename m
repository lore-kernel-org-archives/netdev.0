From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: tcp: security_sk_alloc() needed for unicast_sock
Date: Fri, 10 Aug 2012 00:05:20 +0200
Message-ID: <1344549920.31104.701.camel@edumazet-glaptop>
References: <50215A7E.8000701@linaro.org>
	 <1344462889.28967.328.camel@edumazet-glaptop>
	 <5022FD9A.4020603@schaufler-ca.com> <1695034.0lrQgQPOMT@sifl>
	 <1344523833.28967.996.camel@edumazet-glaptop>
	 <CACLa4ptkvKj2GT4ZL+msMuWOHW885Hugk8nz3hvptOoY9-totw@mail.gmail.com>
	 <1344547743.31104.582.camel@edumazet-glaptop>
	 <5024313F.1010404@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Paris <eparis@parisplace.org>,
	Paul Moore <paul@paul-moore.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	lkml <linux-kernel@vger.kernel.org>,
	James Morris <james.l.morris@oracle.com>,
	selinux@tycho.nsa.gov, john.johansen@canonical.com,
	LSM <linux-security-module@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <5024313F.1010404@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-08-09 at 14:53 -0700, Casey Schaufler wrote:
> On 8/9/2012 2:29 PM, Eric Dumazet wrote:

> > smack_sk_alloc_security() uses smk_of_current() : What can be the
> > meaning of smk_of_current() in the context of 'kernel' sockets...
> 
> Yes, and all of it's callers - to date - have had an appropriate
> value of current. It is using the API in the way it is supposed to.
> It is assuming a properly formed socket. You want to give it a
> cobbled together partial socket structure without task context.
> Your predecessor did not have this problem.

My predecessor ? You mean before the patch ?

tcp socket was preallocated by at kernel boot time.

What is the 'user' owning this socket ?

You guys focus on an implementation detail of TCP stack.
You should never use this fake socket.

I repeat : There are no true socket for these control packets.

If you want them, then you'll have to add fields in timewait socket.

I can decide to rewrite the whole thing just building a TCP packet on
its own, and send it without any fake socket.

Some guy 15 years ago tried to reuse some high level functions, able to
build super packets and use sophisticated tricks, while we only want so
send a 40 or 60 bytes packet.



