From: Stefan Rompf <srompf@isg.de>
Subject: Re: Patch resubmission: RFC2863 operstatus for 2.5.49
Date: Tue, 26 Nov 2002 16:36:35 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DE39503.4A24DCB2@isg.de>
References: <3DE33D6D.25B9C9B4@isg.de> <20021126.021546.91313706.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

> This locking below achieves nothing.

Ok, so I was too cautious by locking read access to a one byte
structure. I'll change that and read additional documentation on SMP ;-)

> Probably something else in
> the device struct can be reused.

Right now, I don't see which. There are other spinlocks available in the
net_device structure, but they are used by the queuing code and we
should not give up the semantic that netif_set_operstate() can be called
from everywhere. One global spinlock may be acceptable for this special
case.

> I also don't think this should be conditional, either we want
> it or we don't.

The conditional stuff is inspired from my first 2.4 version, but I'm
happy to remove it.

Btw, can you also have a look the 2.4 backport of my link state
notification feature (posting available under
http://marc.theaimsgroup.com/?l=linux-netdev&m=103722967214290&w=2, just
one typo fixed in Configure.help since then). Is this stuff acceptable
for 2.4?

Cheers, Stefan
