From: "David S. Miller" <davem@davemloft.net>
Subject: Re: skb_checksum_help
Date: Tue, 25 Jan 2005 12:50:19 -0800
Message-ID: <20050125125019.5ca32de1.davem@davemloft.net>
References: <20050124234515.GA31837@postel.suug.ch>
	<20050125000759.GA15883@gondor.apana.org.au>
	<20050124164049.3b939791.davem@davemloft.net>
	<20050125014538.GB31837@postel.suug.ch>
	<20050125014838.GA16637@gondor.apana.org.au>
	<20050125020118.GC31837@postel.suug.ch>
	<20050124180354.63ae600d.davem@davemloft.net>
	<20050125022431.GD31837@postel.suug.ch>
	<20050124194328.20a106de.davem@davemloft.net>
	<20050125143319.GF31837@postel.suug.ch>
	<20050125203607.GG31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, david@davidcoulson.net, kaber@trash.net,
        greearb@candelatech.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050125203607.GG31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 25 Jan 2005 21:36:07 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> NETIF_F_IP_CSUM|NETIF_F_HW_CSUM:
>   Assuming that the vlan accel code can always do the checksumming
>   if the card can do it.

I bet there are cards that don't have VLAN hw assist yet
can properly checksum such packets.  One example I am counting
on to fit this property is the 3c59x.

This is why I'm suggesting some kind of inheritance indication
explicitly from the real_dev driver.  Perhaps even something
like:

	unsigned int vlan_inherited_features;

in the netdev struct.

Basically, I don't want to preclude inheritance of checksumming
capability just because the device doesn't have VLAN assist.
