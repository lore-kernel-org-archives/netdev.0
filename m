From: "David S. Miller" <davem@davemloft.net>
Subject: Re: skb_checksum_help
Date: Mon, 24 Jan 2005 19:43:28 -0800
Message-ID: <20050124194328.20a106de.davem@davemloft.net>
References: <41F50B6C.6010107@davidcoulson.net>
	<20050124151510.GV23931@postel.suug.ch>
	<20050124225423.GA15405@gondor.apana.org.au>
	<20050124234515.GA31837@postel.suug.ch>
	<20050125000759.GA15883@gondor.apana.org.au>
	<20050124164049.3b939791.davem@davemloft.net>
	<20050125014538.GB31837@postel.suug.ch>
	<20050125014838.GA16637@gondor.apana.org.au>
	<20050125020118.GC31837@postel.suug.ch>
	<20050124180354.63ae600d.davem@davemloft.net>
	<20050125022431.GD31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, david@davidcoulson.net, kaber@trash.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050125022431.GD31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 25 Jan 2005 03:24:31 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> This of course explains it, didn't think of that. I thought it would
> inherit the checksumming features.

It should, but only in very limited cases.

For example, it probably only works properly when HW vlan assist
is being used on TX.  It's likely that the chips which don't support
VLAN assist also can't handle VLAN headers in their TX checksumming
engine.

Because it is very chip dependant whether this works or not in
any case, we should probably create a special features flag for
this.  Something like NETIF_F_VLAN_INHERIT_FEATURES.
