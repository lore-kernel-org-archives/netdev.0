From: Logan Gunthorpe <logang@deltatee.com>
Subject: BUG: cxgb4 is broken in v4.12-rc1
Date: Mon, 15 May 2017 16:36:59 -0600
Message-ID: <f5966da1-44e7-ebf7-c5df-28f815a77424@deltatee.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------66785A71D4ECA4AF2417D27A"
Cc: "David S. Miller" <davem@davemloft.net>,
        Stephen Bates <sbates@raithlin.com>,
        Steve Wise <swise@opengridcomputing.com>,
        netdev@vger.kernel.org
To: Ganesh Goudar <ganeshgr@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ale.deltatee.com ([207.54.116.67]:33145 "EHLO ale.deltatee.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751961AbdEOWhE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 18:37:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------66785A71D4ECA4AF2417D27A
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

Hi,

With rc1 my T62100-LP-CR no longer functions correctly. Everything
appears fine but the link never goes into the UP state. I have one peer
with an older (functioning) kernel and the other peer on rc1.

I've bisected to find this is the offending commit:

3bb4858fd: cxgb4: avoid disabling FEC by default

I've also attached a bisect log.

Let me know if you need anything else.

Thanks,

Logan

--------------66785A71D4ECA4AF2417D27A
Content-Type: text/x-log;
 name="bisect.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="bisect.log"

git bisect start
# bad: [2ea659a9ef488125eb46da6eb571de5eae5c43f6] Linux 4.12-rc1
git bisect bad 2ea659a9ef488125eb46da6eb571de5eae5c43f6
# good: [c02ed2e75ef4c74e41e421acb4ef1494671585e8] Linux 4.11-rc4
git bisect good c02ed2e75ef4c74e41e421acb4ef1494671585e8
# good: [2f34c1231bfc9f2550f934acb268ac7315fb3837] Merge tag 'drm-for-v4.12' of git://people.freedesktop.org/~airlied/linux
git bisect good 2f34c1231bfc9f2550f934acb268ac7315fb3837
# good: [c6a677c6f37bb7abc85ba7e3465e82b9f7eb1d91] Merge tag 'staging-4.12-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging
git bisect good c6a677c6f37bb7abc85ba7e3465e82b9f7eb1d91
# good: [0ff4c01b279a590a2826ade9321ad8c7ca5a1b6c] Merge tag 'armsoc-arm64' of git://git.kernel.org/pub/scm/linux/kernel/git/arm/arm-soc
git bisect good 0ff4c01b279a590a2826ade9321ad8c7ca5a1b6c
# bad: [c70422f760c120480fee4de6c38804c72aa26bc1] Merge tag 'nfsd-4.12' of git://linux-nfs.org/~bfields/linux
git bisect bad c70422f760c120480fee4de6c38804c72aa26bc1
# bad: [56868a460b83c0f93d339256a81064d89aadae8e] Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide
git bisect bad 56868a460b83c0f93d339256a81064d89aadae8e
# good: [ae706bebd6a172a6adf9f63d1a77b8ed49e998a6] Merge tag 'juno-fixes-4.12' of git://git.kernel.org/pub/scm/linux/kernel/git/sudeep.holla/linux into next/dt64
git bisect good ae706bebd6a172a6adf9f63d1a77b8ed49e998a6
# good: [ecc721a72c121e8b641d68efd24a225abedb9a30] Merge tag 'pwm/for-4.12-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/thierry.reding/linux-pwm
git bisect good ecc721a72c121e8b641d68efd24a225abedb9a30
# bad: [657831ffc38e30092a2d5f03d385d710eb88b09a] dccp/tcp: do not inherit mc_list from parent
git bisect bad 657831ffc38e30092a2d5f03d385d710eb88b09a
# bad: [b210aeaedfc47ab8a86fbdcad46caf1e49cc0e37] Merge branch 'stmmac-pci-fix-crash-on-Intel-Galileo-Gen2'
git bisect bad b210aeaedfc47ab8a86fbdcad46caf1e49cc0e37
# good: [ac45bd93a5035c2f39c9862b8b6ed692db0fdc87] bnxt_en: allocate enough space for ->ntp_fltr_bmap
git bisect good ac45bd93a5035c2f39c9862b8b6ed692db0fdc87
# bad: [0d0e57697f162da4aa218b5feafe614fb666db07] bpf: don't let ldimm64 leak map addresses on unprivileged
git bisect bad 0d0e57697f162da4aa218b5feafe614fb666db07
# bad: [3bb4858fda1cac2ae677edb5134932af4c7f8ff8] cxgb4: avoid disabling FEC by default
git bisect bad 3bb4858fda1cac2ae677edb5134932af4c7f8ff8
# good: [8ce7aaaa9797f944ad2f50e5160c8a20a473aedf] net: dsa: loop: Check for memory allocation failure
git bisect good 8ce7aaaa9797f944ad2f50e5160c8a20a473aedf
# first bad commit: [3bb4858fda1cac2ae677edb5134932af4c7f8ff8] cxgb4: avoid disabling FEC by default

--------------66785A71D4ECA4AF2417D27A--
