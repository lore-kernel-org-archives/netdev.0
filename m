From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 0/3] net: drivers/net: include/net: Remove unnecessary semicolons
Date: Fri,  3 Jun 2011 14:51:18 -0700
Message-ID: <cover.1307137351.git.joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2499 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753980Ab1FCVvW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2011 17:51:22 -0400
Received: from Joe-Laptop.home (unknown [192.168.1.162])
	by mail.perches.com (Postfix) with ESMTP id E2AD724368
	for <netdev@vger.kernel.org>; Fri,  3 Jun 2011 14:51:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Done via perl script:

my $match_balanced_parentheses = qr/(\((?:[^\(\)]++|(?-1))*\))/;
my $match_balanced_braces      = qr/(\{(?:[^\{\}]++|(?-1))*\})/;

foreach my $file (@ARGV) {
    my $f;
    my $text;
    my $oldtext;

    next if ((-d $file));

    open($f, '<', $file)
	or die "$P: Can't open $file for read\n";
    $oldtext = do { local($/) ; <$f> };
    close($f);

    next if ($oldtext eq "");

    $text = $oldtext;

    my $count = 0;
    do {
	$count = 0;
	$count += $text =~ s@\b(if\s*${match_balanced_parentheses}\s*)${match_balanced_braces}\s*;@"$1$3"@egx;
	$count += $text =~ s@\b(while\s*${match_balanced_parentheses}\s*)${match_balanced_braces}\s*;@"$1$3"@egx;
	$count += $text =~ s@\b(for\s*${match_balanced_parentheses}\s*)${match_balanced_braces}\s*;@"$1$3"@egx;
	$count += $text =~ s@\b(switch\s*${match_balanced_parentheses}\s*)${match_balanced_braces}\s*;@"$1$3"@egx;
    } while ($count > 0);

    if ($text ne $oldtext) {
	my $newfile = $file;

	open($f, '>', $newfile)
	    or die "$P: Can't open $newfile for write\n";
	print $f $text;
	close($f);

    }
}

Joe Perches (3):
  net: Remove unnecessary semicolons
  drivers/net: Remove unnecessary semicolons
  include/net: Remove unnecessary semicolons

 drivers/net/amd8111e.c                  |    2 +-
 drivers/net/cxgb4/cxgb4_main.c          |    2 +-
 drivers/net/enic/enic_main.c            |    2 +-
 drivers/net/irda/via-ircc.h             |    2 +-
 drivers/net/iseries_veth.c              |    4 ++--
 drivers/net/ixgbe/ixgbe_82599.c         |    4 ++--
 drivers/net/ixgbe/ixgbe_common.c        |    4 ++--
 drivers/net/myri10ge/myri10ge.c         |    2 +-
 drivers/net/netxen/netxen_nic_init.c    |    2 +-
 drivers/net/ps3_gelic_net.c             |    2 +-
 drivers/net/slhc.c                      |    2 +-
 drivers/net/sungem.c                    |    2 +-
 drivers/net/tokenring/3c359.c           |    6 ++++--
 drivers/net/tokenring/ibmtr.c           |    2 +-
 drivers/net/tun.c                       |    2 +-
 drivers/net/via-velocity.c              |    2 +-
 drivers/net/wireless/b43/main.c         |    2 +-
 drivers/net/wireless/b43legacy/main.c   |    2 +-
 drivers/net/wireless/iwmc3200wifi/fw.c  |    2 +-
 drivers/net/wireless/orinoco/main.c     |    2 +-
 drivers/net/wireless/rt2x00/rt2800lib.c |    2 +-
 drivers/net/wireless/rt2x00/rt2800pci.c |    2 +-
 drivers/net/znet.c                      |    2 +-
 include/net/sctp/sctp.h                 |    4 ++--
 net/batman-adv/hard-interface.c         |    2 +-
 net/bluetooth/hci_core.c                |    4 ++--
 net/sunrpc/auth.c                       |    2 +-
 27 files changed, 35 insertions(+), 33 deletions(-)

-- 
1.7.5.rc3.dirty

