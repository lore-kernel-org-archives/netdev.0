From: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
Subject: [IPSec] connect: Resource temporarily unavailable
Date: Tue, 24 Feb 2004 14:48:41 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1077630520.799.7.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When using Racoon to manage SAs between two IPv4/IPSec hosts running 2.6
kernels and IPSec in transport mode with mandatory ESP/AH support, the
first packet exchange between both hosts triggers IKE Phase 1 but,
instead of queueing the userspace packet that triggered the IKE exchange
until IKE Phase 2 has ended and the SA has been established, userspace
receives the following errpr:

connect: Resource temporarily unavailable

Any further attempt to exchange packets between both hosts succeeds
after a while, (once the IKE Phase 2 ends and the SA has been correctly
established).

Is this a bug? Shouldn't the kernel queue (hold) userspace packets until
IKE Phase 2 has completed (either successfully or with error)? Why am I
receiving "connect: Resource temporarily unavailable" error when there
is no SA set up?

This is reproducible by either pinging or telnetting the other peer or
the IPSec link. Both hosts are running 2.6.3 kernels and ipsec-tools
0.2.2. Once IKE Phase 2 ends, ping and telnet work with no error and
tcpdump reveals that AH/ESP protocols are being used.
