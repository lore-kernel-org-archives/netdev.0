From: Luigi Rizzo <rizzo@iet.unipi.it>
Subject: netmap, VALE and netmap pipes
Date: Mon, 17 Feb 2014 02:11:21 -0800
Message-ID: <CA+hQ2+gbs9aBneUaDGAnKVoPHspzc=5o+h+f_K=T+Cy8sRxr+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "freebsd-net@freebsd.org" <net@freebsd.org>
Return-path: <owner-freebsd-net@freebsd.org>
List-Unsubscribe: <http://lists.freebsd.org/mailman/options/freebsd-net>,
 <mailto:freebsd-net-request@freebsd.org?subject=unsubscribe>
List-Archive: <http://lists.freebsd.org/pipermail/freebsd-net/>
List-Post: <mailto:freebsd-net@freebsd.org>
List-Help: <mailto:freebsd-net-request@freebsd.org?subject=help>
List-Subscribe: <http://lists.freebsd.org/mailman/listinfo/freebsd-net>,
 <mailto:freebsd-net-request@freebsd.org?subject=subscribe>
Errors-To: owner-freebsd-net@freebsd.org
Sender: owner-freebsd-net@freebsd.org
List-Id: netdev.vger.kernel.org

Hi,
we have recently made a few extensions to netmap/VALE and put various
pieces of code on public repositories, so i thought i'd share the
pointers. All the code below runs with equal features and performance
on FreeBSD and Linux, and we are trying to upstream it in the relevant
projects if possible (as an example, QEMU recently added a netmap backend),
at which point some of these clone repositories will become unnecessary.

See http://info.iet.unipi.it/~luigi/netmap for more details.

https://code.google.com/p/netmap/
    The latest netmap code for FreeBSD/Linux. It has native support
    for certain NICs; emulated netmap over unmodified drivers;
    enhanced parallelism in the VALE switch (20 Mpps/source, scaling
    up to ~50Mpps); and a new feature called "netmap pipe" that
    does zero-copy blocking I/O at over 100 Mpps.
        Other features are the ability to allocate tons of extra
    netmap buffers, and configurable sharing of memory among NICs,
    VALE ports and netmap pipes. This increases the opportunity for
    zero copy operation.
        The user API is also greatly simplified, with a naming
    scheme that permits easy access to all types of ports including
    individual NIC queues.

https://code.google.com/p/netmap-libpcap
    a netmap-enabled version of libpcap. With this, basically any
    pcap client can read/write traffic at 10+ Mpps, with zerocopy
    reads and (soon) support for zerocopy writes. Whether applications
    can cope with these packet rates, of course, is another story.

https://code.google.com/p/netmap-click
    a netmap-enabled version of the Click Modular Router.  This
    code matches the current version of netmap, supporting all
    features (including netmap pipes).

https://code.google.com/p/netmap-ipfw
    a netmap-enabled, userspace version of the ipfw firewall and
    dummynet network emulator. This version reaches 7-10 Mpps for
    filtering and over 2.5 Mpps for emulation.


Hope you'll find it useful.

cheers
luigi
_______________________________________________
freebsd-net@freebsd.org mailing list
http://lists.freebsd.org/mailman/listinfo/freebsd-net
To unsubscribe, send any mail to "freebsd-net-unsubscribe@freebsd.org"
