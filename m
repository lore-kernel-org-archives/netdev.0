From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Sat, 12 Feb 2005 11:41:32 -0800
Message-ID: <20050212114132.5f7b7ffe.davem@davemloft.net>
References: <0525M9211@server5.heliogroup.fr>
	<20050211150420.74737b2e@dxpl.pdx.osdl.net>
	<20050211170740.2608419b.davem@davemloft.net>
	<20050212141641.GA27456@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, hubert.tonneau@fullpliant.org, romieu@fr.zoreil.com,
        kuznet@ms2.inr.ac.ru, niv@us.ibm.com, rick.jones2@hp.com,
        netdev@oss.sgi.com
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20050212141641.GA27456@yakov.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 12 Feb 2005 17:16:41 +0300
Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:

> > This set of data frames you quoted are all full, and
> > are tightly interspaced.  It looks exactly like a TSO
> > frame, which we certainly set PSH on, but the TSO
> > engine is dropping it aparently.
 ...
> Or it was two one-segment frames.

Even ignoring my TSO changes, we should be seeing at a minimum
1/2 window PSH settings which we're not as far as I can tell.
(this is due to the forced_push() test in net/ipv4/tcp.c)

This also points out a bug in my TSO PSH patch, I should be
updating tp->pushed_seq shouldn't I?  Question is, what to
set it to?  I think correct value is TCP_SKB_CB(skb)->end_seq.

> I.e. let's disable TSO in 2.6.9 and look.

I believe this experiment had been performed already.  Stephen,
isn't that the case?
