From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH BUGFIX -rc4] Smack: Respect 'unlabeled' netlabel mode
Date: Fri, 30 May 2008 16:10:37 -0700 (PDT)
Message-ID: <538684.41302.qm@web36603.mail.mud.yahoo.com>
References: <20080530233603.GA2994@ubuntu>
Reply-To: casey@schaufler-ca.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-security-module@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080530233603.GA2994@ubuntu>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- "Ahmed S. Darwish" <darwish.07@gmail.com> wrote:

> Hi all,
> 
> In case of Smack 'unlabeled' netlabel option, Smack passes a _zero_
> initialized 'secattr' to label a packet/sock. This causes an 
> [unfound domain label error]/-ENOENT by netlbl_sock_setattr().
> Above Netlabel failure leads to Smack socket hooks failure causing 
> an always-on socket() -EPERM error.
> 
> Such packets should have a netlabel domain agreed with netlabel to 
> represent unlabeled packets. Fortunately Smack net ambient label 
> packets are agreed with netlabel to be treated as unlabeled packets. 
> 
> Treat all packets coming out from a 'unlabeled' Smack system as
> coming from the smack net ambient label.

To date the behavior of a Smack system running with nltype
unlabeled has been carefully undefined. The way you're defining
it will result in a system in which only processes running with
the ambient label will be able to use sockets, unless I'm reading
the code incorrectly. This seems like "correct" behavior, but
I don't think it is what those who've tried it would expect.


Casey Schaufler
casey@schaufler-ca.com
