From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance under stress
Date: Tue, 20 May 2003 17:09:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030521000936.GA19077@netnation.com>
References: <Pine.LNX.4.51.0305191408490.1795@ns.istop.com> <20030519154852.I39024@shell.cyberus.ca> <20030520011053.GB10419@netnation.com> <20030519.181405.35017608.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@shell.cyberus.ca, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030519.181405.35017608.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, May 19, 2003 at 06:14:05PM -0700, David S. Miller wrote:

> I bet you have been, the weakness in the hash has been very well
> publicized and the script kiddies aren't using the truly random
> version of the attacks anymore.  Just google for juno-z.101f.c, this
> (or some derivative) is the DoS people attack program are actually
> using.

Hmm, I see no difference.  I've been using juno-z.101f.c to spam a test
box (PIII 800 Mhz, 3C996B/BCM5701), and the box easily chokes when I hit
it with my pimpin' 466 MHz Celery (running at 542 MHz) with an eepro100.

NAPI is definitely impressive, though.  When hitting it with my "udpspam"
program which doesn't quite saturate the CPU (and doesn't spoof the
source), it does about 80k interrupts/sec and behaves normally.  When I
run "juno" on it, eth0 interrupts stop entirely and it works nicely in
polling mode.  Userspace still works on the console, but remote SSH is a
bit dodgy because it still drops about half of the rx packets due to CPU
saturation.  Juno reports sending 4,272,266 bytes/second, which is
34,178,128 bits/second.

It's rather difficult to follow, but I don't see any "h4r h4r, expl0it
th3 L1nux h4sh" comments or anything in the code that seems to attempt to
exploit the hash algorithms in (older) Linux.  It seems to be using very
crappy psuedo-random code to generate source IPs.  Perhaps another
variant actually attempts to exploit the hash.

Once I figure out a good way of getting near but not quite saturation, I
will attempt to compare -rc1 and -rc2 to see if the (crappy) random
source handling capacity has increased at all.

Simon-
