From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Sat, 12 Feb 2005 23:03:18 +0300
Message-ID: <20050212200318.GB28895@yakov.inr.ac.ru>
References: <0525M9211@server5.heliogroup.fr> <20050211150420.74737b2e@dxpl.pdx.osdl.net> <20050211170740.2608419b.davem@davemloft.net> <20050212141641.GA27456@yakov.inr.ac.ru> <20050212114132.5f7b7ffe.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, shemminger@osdl.org,
        hubert.tonneau@fullpliant.org, romieu@fr.zoreil.com, niv@us.ibm.com,
        rick.jones2@hp.com, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050212114132.5f7b7ffe.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> set it to?  I think correct value is TCP_SKB_CB(skb)->end_seq.

Yup. But it does not matter. When it is not advanced, it does not make
PSHs more rare.

Actually, that anti-MacOS never worked well. If segment with forced PSH
was not transmitted in time, even forced PSHs could be deleted.
Your patch with setting PSH right before (or in) tcp_transmit_skb() must
work. Unless these segments are not tso.


> > I.e. let's disable TSO in 2.6.9 and look.
> 
> I believe this experiment had been performed already.

I saw only tests with TSO. And 2.6.9 showed exactly the same weird
behaviour. Only 2.6.9 did not slow start and we had only a few of 200msec
gaps.

Alexey
