From: "David S. Miller" <davem@redhat.com>
Subject: Re: dev_add_pack and hardware checksumming
Date: Sun, 17 Aug 2003 22:38:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030817223851.5185bdee.davem@redhat.com>
References: <20030818033711.GA21360@vana.vc.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Petr Vandrovec <vandrove@vc.cvut.cz>
In-Reply-To: <20030818033711.GA21360@vana.vc.cvut.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 05:37:11 +0200
Petr Vandrovec <vandrove@vc.cvut.cz> wrote:

>   For me it would be best if dev_queue_xmit_nit could just leave
> skb->h.raw alone,

The AF_PACKET layer depends upon skb->h.raw being set a certain
way.  Have a look at the dev_add_pack() registered hooks that
net/packet/af_packet.c uses.

> Other choice is doing checksumming in dev_queue_xmit_nit itself,
> before passing skb down to the registered packet handlers.

This is not an option either.  We're specifically not going to
undo checksum offloading just because tcpdump or some other
kind of tap is installed.
