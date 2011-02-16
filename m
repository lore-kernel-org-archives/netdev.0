From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 1/1] tproxy: do not assign timewait sockets to skb->sk
Date: Wed, 16 Feb 2011 12:30:40 +0100
Message-ID: <20110216113040.GE8821@Chamillionaire.breakpoint.cc>
References: <1297683874-10188-1-git-send-email-fw@strlen.de>
 <4D594F9E.2090100@trash.net>
 <4D5B90C7.5040603@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, Balazs Scheidler <bazsi@balabit.hu>
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D5B90C7.5040603@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

KOVACS Krisztian <hidden@balabit.hu> wrote:
> On 02/14/2011 04:51 PM, Patrick McHardy wrote:
> >Am 14.02.2011 12:44, schrieb Florian Westphal:
> >>Assigning a socket in timewait state to skb->sk can trigger
> >>kernel oops, e.g. in nfnetlink_log, which does:
> >>
> >>if (skb->sk) {
> >>         read_lock_bh(&skb->sk->sk_callback_lock);
> >>         if (skb->sk->sk_socket&&  skb->sk->sk_socket->file) ...
> >>
> >>in the timewait case, accessing sk->sk_callback_lock and sk->sk_socket
> >>is invalid.
> >>
> >>Either all of these spots will need to add a test for sk->sk_state != TCP_TIME_WAIT,
> >>or xt_TPROXY must not assign a timewait socket to skb->sk.
> >>
> >>This does the latter.
> >>
> >>If a TW socket is found, assign the tproxy nfmark, but skip the skb->sk assignment,
> >>thus mimicking behaviour of a '-m socket .. -j MARK/ACCEPT' re-routing rule.
> >>
> >>The 'SYN to TW socket' case is left unchanged -- we try to redirect to the
> >>listener socket.
> >>
> >>Cc: Balazs Scheidler<bazsi@balabit.hu>
> >>Cc: KOVACS Krisztian<hidden@balabit.hu>
> >>Signed-off-by: Florian Westphal<fwestphal@astaro.com>
> >
> >Looks fine to me. Balazs. Krisztian, any objections?
> 
> Seems to be OK, as far as I can see.
> 
> Florian, did you make sure the tests still run after applying this patch?
> 
> http://git.balabit.hu/?p=bazsi/tproxy-test.git;a=summary

Thanks for the hint, I cloned this and ran it on my test setup:
./tproxy-test.py
[..]
PASS: ('192.168.10.8', 50080), we got a connection as we deserved
PASS: everything is fine
