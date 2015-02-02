From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/3] Restore UFO support to virtio_net devices
Date: Mon, 02 Feb 2015 13:11:58 -0800 (PST)
Message-ID: <20150202.131158.2302675247156677150.davem@davemloft.net>
References: <1422889269-16007-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	hannes@stressinduktion.org, ben@decadent.org.uk
To: vyasevich@gmail.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1422889269-16007-1-git-send-email-vyasevic@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


Vlad, this still fails the same way.

[davem@dokdo net]$ make -s -j8
kernel/Makefile:132: *** No X.509 certificates found ***
kernel/Makefile:132: *** No X.509 certificates found ***
net/built-in.o: In function `udp6_ufo_fragment':
udp_offload.c:(.text+0x103514): undefined reference to `ipv6_select_ident'
make: *** [vmlinux] Error 1

You're putting ipv6_select_ident() into the ipv6 module via
ip6_output.c, but that means that code like udp_offload.c which is
built statically into the kernel can't see the symbol.

Please build allmodconfig, that is the exact build I use to test your
and everyone else's changes.
