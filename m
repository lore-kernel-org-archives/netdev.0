From: Martyn Welch <martyn.welch@ge.com>
Subject: Gianfar driver failing on MPC8641D based board
Date: Fri, 05 Feb 2010 14:00:40 +0000
Message-ID: <4B6C2488.3060403@ge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Anton Vorontsov <avorontsov@ru.mvista.com>,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>, davem@davemloft.net
To: linuxppc-dev list <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

I have recently attempted to boot an 8641D based board from an NFS root.
The boot process grinds to a halt not long after the first access of the
NFS root and I receive multiple "nfs: server 192.168.0.1 not responding,
still trying" messages. Wireshark suggests that there is no further
traffic from this board at this point on. The NFS server seems to
eventually try sending duplicate packets it's already sent, which
results in "nfs: server 192.168.0.1 OK" messages, but the "not
responding" messages resume with no further traffic from the board.

I am able to boot to a ramdisk fine and the network seems to work -
though I haven't really pushed the interface from it.

I have attempted to git bisect, though I wasn't able to get much further
than discovering the problem was introduced in the 2.6.33 merge window -
at which point the gianfar network driver fails to compile (I have tried
to git bisect skip many, many times to no avail).

NFS booting fails for this board on todays linux-next, the master branch
of Kumar's PPC tree and the head of the main tree. I have also been able
to NFS boot from a random x86 based board that I have, using the head of
the main tree and the linux-next tree.

Copying the gianfar drivers from 2.6.32 into the head of the main tree
restores the correct behaviour and I'm able to NFS boot. I have heard
from others that the latest drivers work on 83xx and 85xx based boards,
but it seems to be broken on at least the 8641D.

I can see there has been a fair amount of work done on the gianfar
driver, I assume that this is a bug introduced by the multiple queue
support, but I'm way out of my depth on this.

I'm also off for the next week - so if I'm quiet, it'll be because of that.

Martyn

-- 
Martyn Welch (Principal Software Engineer)   |   Registered in England and
GE Intelligent Platforms                     |   Wales (3828642) at 100
T +44(0)127322748                            |   Barbirolli Square, Manchester,
E martyn.welch@ge.com                        |   M2 3AB  VAT:GB 927559189
