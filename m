From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 00/21] ethtool refactoring and misc changes
Date: Tue, 1 Nov 2011 22:35:00 +0000
Message-ID: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:33766 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250Ab1KAWfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 18:35:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As I looked into supporting features cleanly within the existing -k/-K
options, it became clear that ethtool was overdue for refactoring.  And
in order to be confident about doing that, I needed to add some tests.

So I intend to push the following changes:

1. Reporting of pause frame autonegotiation.  I don't believe this
   requires a new command in the kernel interface; it just needs drivers
   to fill out the AN flags.

2. Minor fixes to manual page and online help.

3. Cleanup of ethtool-bitops.h and ethtool-util.h.

4. Encapsulate shared command state into a structure passed into each
   sub-command function (and several others).

5. Test argument parsing.  Currently this just checks that each command
   line is accepted or rejected as expected.

6. For each sub-command (option), move all argument parsing into the
   function that implements it.  Move the associated static variables
   likewise.  Declare static constants as const, so that there are no
   static variables left (outside of the test wrapper).

7. Run the main ethtool code in the same process as the test code.
   This will allow for test cases that cover the ioctl requests and
   responses.

Ben.

Ben Hutchings (21):
  Report pause frame autonegotiation result
  ethtool.8: Fix initial blank line/page
  Combine ethtool-{bitops,util}.h into internal.h
  Fix type of bit-number parameter to set_bit() and clear_bit()
  ethtool.8: Change device name metavariable from 'ethX' to 'devname'
  ethtool.8: Allow line-break in description of parameters after -N
  Fix format of help text for -f option
  Use standard indentation for definition of struct option args
  Encapsulate command context in a structure
  Add test cases for command-line parsing
  Add more test cases for command-line parsing
  Move argument parsing to sub-command functions
  Support arbitrary numbers of option names for each mode
  Fix reference to cmdline_ring in do_schannels()
  Convert cmdline_msglvl into array of named flags; convert back at
    run-time
  Replace global devname variable with a field in struct cmd_context
  Change most static global variables into automatic variables
  rxclass: Replace global rmgr with automatic variable/parameter
  Declare static variables const as appropriate
  Run tests in-process
  Rearrange definitions and remove unnecessary forward declarations

 Makefile.am                  |    7 +-
 amd8111e.c                   |    2 +-
 at76c50x-usb.c               |    2 +-
 configure.ac                 |    1 +
 de2104x.c                    |    2 +-
 e100.c                       |    2 +-
 e1000.c                      |    2 +-
 ethtool-bitops.h             |   25 -
 ethtool.8.in                 |   70 +-
 ethtool.c                    | 2352 +++++++++++++++++++-----------------------
 fec_8xx.c                    |    2 +-
 ibm_emac.c                   |    2 +-
 igb.c                        |    2 +-
 ethtool-util.h => internal.h |   57 +-
 ixgb.c                       |    2 +-
 ixgbe.c                      |    2 +-
 marvell.c                    |    2 +-
 natsemi.c                    |    2 +-
 pcnet32.c                    |    2 +-
 realtek.c                    |    2 +-
 rxclass.c                    |  129 +--
 sfc.c                        |    2 +-
 smsc911x.c                   |    2 +-
 stmmac.c                     |    2 +-
 test-cmdline.c               |  240 +++++
 test-common.c                |  101 ++
 tg3.c                        |    2 +-
 vioc.c                       |    2 +-
 28 files changed, 1565 insertions(+), 1455 deletions(-)
 delete mode 100644 ethtool-bitops.h
 rename ethtool-util.h => internal.h (71%)
 create mode 100644 test-cmdline.c
 create mode 100644 test-common.c

-- 
1.7.4.4


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
