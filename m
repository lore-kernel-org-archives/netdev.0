From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.10 TCP troubles -- suggested patch
Date: Tue, 15 Feb 2005 15:26:51 -0800
Message-ID: <20050215152651.58f5ccc0.davem@davemloft.net>
References: <0525M9211@server5.heliogroup.fr>
	<20050211150420.74737b2e@dxpl.pdx.osdl.net>
	<20050211170740.2608419b.davem@davemloft.net>
	<20050212141641.GA27456@yakov.inr.ac.ru>
	<20050212114132.5f7b7ffe.davem@davemloft.net>
	<20050212200318.GB28895@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, shemminger@osdl.org, hubert.tonneau@fullpliant.org,
        romieu@fr.zoreil.com, niv@us.ibm.com, rick.jones2@hp.com,
        netdev@oss.sgi.com
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20050212200318.GB28895@yakov.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 12 Feb 2005 23:03:18 +0300
Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:

> Actually, that anti-MacOS never worked well. If segment with forced PSH
> was not transmitted in time, even forced PSHs could be deleted.
> Your patch with setting PSH right before (or in) tcp_transmit_skb() must
> work. Unless these segments are not tso.

Yes, it never did work well.  But now we understand more deeply the
nature of this beast, we can probably refine it.

In short, for properly working TCP stream with no drops and no
reordering, Darwin delays ACKs until delack timer fires or PSH
is seen :-)
