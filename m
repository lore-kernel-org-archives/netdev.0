From: "David S. Miller" <davem@davemloft.net>
Subject: Re: skb_checksum_help
Date: Mon, 24 Jan 2005 18:03:54 -0800
Message-ID: <20050124180354.63ae600d.davem@davemloft.net>
References: <20050123202715.281ac87c.davem@davemloft.net>
	<20050124121610.GP23931@postel.suug.ch>
	<41F50B6C.6010107@davidcoulson.net>
	<20050124151510.GV23931@postel.suug.ch>
	<20050124225423.GA15405@gondor.apana.org.au>
	<20050124234515.GA31837@postel.suug.ch>
	<20050125000759.GA15883@gondor.apana.org.au>
	<20050124164049.3b939791.davem@davemloft.net>
	<20050125014538.GB31837@postel.suug.ch>
	<20050125014838.GA16637@gondor.apana.org.au>
	<20050125020118.GC31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, david@davidcoulson.net, kaber@trash.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050125020118.GC31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 25 Jan 2005 03:01:18 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> * Herbert Xu <20050125014838.GA16637@gondor.apana.org.au> 2005-01-25 12:48
> > On Tue, Jan 25, 2005 at 02:45:38AM +0100, Thomas Graf wrote:
> > > 
> > > Still, one problem remains, even if ip_summed was incorrect,
> > > skb_checksum_help should never be called in dev_queue_xmit for the
> > > acenic driver since it sets NETIF_F_IP_CSUM. For some reason, features
> > > is set to 0 while checking for it.
> > 
> > Didn't he say that he cleared the features bits in the acenic driver?
> 
> He changed it back to the original version, I just checked with him.
> 
> > BTW, is he using acenic for both the LAN and the WAN? If he's only
> > using it on the WAN side, then the LAN side might not be CSUM capable.
> 
> The packets get routed back over the same physical interface.

I think I see what is happening, it's the virtual VLAN device which
has dev->features set to zero not the acenic's netdev struct.
