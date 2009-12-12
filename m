From: Yinghai Lu <yhlu.kernel@gmail.com>
Subject: Re: nfs broken in net-next? -- now in mainline -- bisected:
	d9f5950f90292f7cc42834338dfd5f44dc4cc4ca
Date: Fri, 11 Dec 2009 21:25:49 -0800
Message-ID: <86802c440912112125v4aa72189ifcc2d16ecbf79cc4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Suresh Jayaraman <sjayaraman@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>, Sridhar Samudrala <sri@us.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:53840 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756369AbZLLFZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2009 00:25:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 9, 2009 at 11:33 PM, Ingo Molnar <mingo@elte.hu> wrote:
>
> * Yinghai Lu <yhlu.kernel@gmail.com> wrote:
>
>> On Thu, Oct 29, 2009 at 2:03 AM, Yinghai Lu <yhlu.kernel@gmail.com> wrote:
>> > On Thu, Oct 29, 2009 at 12:23 AM, Suresh Jayaraman <sjayaraman@suse.de> wrote:
>> >> On 10/29/2009 01:43 AM, Yinghai Lu wrote:
>> >>> pk12-3214-189-102:~ # mount -t nfs 10.6.75.100:/data/shared/pxeboot /x
>> >>> mount.nfs: rpc.statd is not running but is required for remote locking.
>> >>> mount.nfs: Either use '-o nolock' to keep locks local, or start statd.
>> >>
>> >> rpc.statd on client should have be started by mount.nfs when a nfs
>> >> filesystem is mounted. Is this not happening for some reason or do you
>> >> see any errors in syslog?
>> >>
>> >>>
>> >>> using opensuse11.1
>> >>>
>> >>
>> >> Are you using 11.1 betas? I know of a problem where non-root user mounts
>> >> fail to start rpc.statd in betas that got fixed later:
>> >>
>> >> http://marc.info/?l=linux-nfs&m=122748525624094&w=2
>> >>
>> >> Is the problem seen only recently (after updating to net-next)?
>> >>
>> >
>> > only happen with net-next.
>> >
>> > linus tree and tip tree are ok.
>> >
>>
>> Finally it reached linus tree and tip.
>
> In the quoted text above it's being disputed that it's a kernel
> regression so i guess your best option is to bisect it (if you can).

[linux-2.6]# git bisect good
d9f5950f90292f7cc42834338dfd5f44dc4cc4ca is first bad commit
commit d9f5950f90292f7cc42834338dfd5f44dc4cc4ca
Author: Sridhar Samudrala <sri@us.ibm.com>
Date:   Wed Oct 7 12:24:25 2009 +0000

    net: Make UFO on master device independent of attached devices

    Now that software UFO is supported, UFO can be enabled on master
    devices like bridge, bond even though the attached device doesn't
    support this feature in hardware.

    This allows UFO to be used between KVM host and guest even when a
    physical interface attached to the bridge doesn't support UFO.

    Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
    Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 0b2424e2c2f3e6f69701e4da909e9e4c83ce2170
cc819b2752e9475ab1cac137ac99b4399328acd7 M      net
[linux-2.6]# git bisect log
git bisect start
# bad: [11bd04f6f35621193311c32e0721142b073a7794] Merge branch
'linux-next' of
git://git.kernel.org/pub/scm/linux/kernel/git/jbarnes/pci-2.6
git bisect bad 11bd04f6f35621193311c32e0721142b073a7794
# good: [22763c5cf3690a681551162c15d34d935308c8d7] Linux 2.6.32
git bisect good 22763c5cf3690a681551162c15d34d935308c8d7
# bad: [d7fc02c7bae7b1cf69269992cf880a43a350cdaa] Merge
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6
git bisect bad d7fc02c7bae7b1cf69269992cf880a43a350cdaa
# bad: [cfb3f91af49dff9b50de6929dc4de06100c4cfa8] ixgbe: handle
parameters for tx and rx EITR, no div0
git bisect bad cfb3f91af49dff9b50de6929dc4de06100c4cfa8
# bad: [b4a77d0dee11db834bebe0cc78c211cfebf0d924] rt2800pci: add
rt2800_regbusy_read() wrapper
git bisect bad b4a77d0dee11db834bebe0cc78c211cfebf0d924
# bad: [b771eee583343782c8b44d2b78cf53c29d0f3303] wl1271: Enable
beacon filtering with the stack
git bisect bad b771eee583343782c8b44d2b78cf53c29d0f3303
# bad: [8aa0f64ac3835a6daf84d0b0e07c4c01d7d8eddc] Merge branch
'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6
git bisect bad 8aa0f64ac3835a6daf84d0b0e07c4c01d7d8eddc
# good: [125b181aec7a67c71234284ecf6d9c729d05deda] staging: Add proper
selection of WIRELESS_EXT and WEXT_PRIV
git bisect good 125b181aec7a67c71234284ecf6d9c729d05deda
# bad: [d9f5950f90292f7cc42834338dfd5f44dc4cc4ca] net: Make UFO on
master device independent of attached devices
git bisect bad d9f5950f90292f7cc42834338dfd5f44dc4cc4ca
# good: [aaba2b3f8213e1d66e71c351fa7a2b1cbd974d3c] gigaset: allow
building without I4L
git bisect good aaba2b3f8213e1d66e71c351fa7a2b1cbd974d3c
# good: [b1c00fe3cf8f54d97d20cdf196145a106f04bd63] dccp ccid-2:
Overhaul CCID naming convention 1/2
git bisect good b1c00fe3cf8f54d97d20cdf196145a106f04bd63
# good: [b301e82cf8104cfddbe5452ebe625bab49597c64] IPv6: use
ipv6_addr_set_v4mapped()
git bisect good b301e82cf8104cfddbe5452ebe625bab49597c64
# good: [9e8342971d44ce86d8567047f5366fc1c06a75ed] econet: Fix
redeclaration of symbol len
git bisect good 9e8342971d44ce86d8567047f5366fc1c06a75ed
# good: [8a6dfd43d1891882f8ca05d73aa7735fb0edae3b] IPv6: Fix 6RD typo
git bisect good 8a6dfd43d1891882f8ca05d73aa7735fb0edae3b
# good: [f86dcc5aa8c7908f2c287e7a211228df599e3e71] udp: dynamically
size hash tables at boot time
git bisect good f86dcc5aa8c7908f2c287e7a211228df599e3e71

after reverting that commit d9f5950f90292f7cc42834338dfd5f44dc4cc4ca,
the nfs client works again.

YH
