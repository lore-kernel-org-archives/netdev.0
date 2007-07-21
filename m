From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 1/1] Allow LSM to use IP address/port number.
Date: Sat, 21 Jul 2007 11:11:43 -0700 (PDT)
Message-ID: <589819.72705.qm@web36605.mail.mud.yahoo.com>
References: <200707211057.ACE39835.WUNtGEPSOFF@I-love.SAKURA.ne.jp>
Reply-To: casey@schaufler-ca.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: Tetsuo Handa <from-netdev@I-love.SAKURA.ne.jp>, kaber@trash.net,
	jmorris@namei.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200707211057.ACE39835.WUNtGEPSOFF@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- Tetsuo Handa <from-netdev@I-love.SAKURA.ne.jp> wrote:

> 
> Hello.
> 
> Patrick McHardy wrote:
> > Quoting Tetsuo:
> > > > So, my approach is not using security context associated with a socket
> > > > but security context associated with a process.
> > Isn't the socket context derived from the process context?
> Not so regarding my case.
> 
> static int smack_sk_alloc_security(struct sock *sk, int family, gfp_t
> priority)
> {
> 	sk->sk_security = current->security;
> 	return 0;
> }
> 
> will not help what I want to do.
> So, I'm not planning to use "sk->sk_security".

Before you go too far down this path please note that the quoted
code is bad* because back pointers from sockets to tasks can't be
reliable. See later versions for more reasonable behavior.

> I'm planning to use "current->security" at accept()/recvmsg() time.

The delivery of packets and the completion of these syscalls are
related but independent events. Be careful about the relationship
between the events and the placement of your checks.


----
* Stephen had good comments on the details on list earlier.

Casey Schaufler
casey@schaufler-ca.com
