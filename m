From: Stephen Frost <sfrost@snowman.net>
Subject: [IPSEC] Too many SADs!
Date: Mon, 21 Mar 2005 09:52:23 -0500
Message-ID: <20050321145223.GA5834@ns.snowman.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Greetings,

  This seems to be the right place for Linux 2.6 ipsec issues:

  Linux 2.6.10 + Virtual Server 1.9.4 + Patrick's IPSEC Netfilter patches
  i386 & amd64 (same source for both)
  Debian Racoon & ipsec-tools 0.5-4
  Setting policies using setkey (not using racoon-tool)
  Using both transport and tunnels

  Problem:

  ===# setkey -D | grep '^[0-9]' | wc -l
  recv: Resource temporarily unavailable
  443
  ===# setkey -D | grep mature | wc -l     
  recv: Resource temporarily unavailable
  443
  ===# setkey -D | grep tunnel | wc -l     
  recv: Resource temporarily unavailable
  18
  ===# setkey -D | grep transport | wc -l
  recv: Resource temporarily unavailable
  425
  ===# ps auwx | grep racoon
  root     17722  3.8  2.0 178268 168252 ?       Ss   Mar20  28:39 /usr/sbin/racoon
  ===# setkey -D -P | grep '^[0-9]' | wc -l
  34
  ===# setkey -D -P | grep transport | wc -l
  20
  ===# setkey -D -P | grep tunnel | wc -l   
  14

  I've seen the number of tunnel SADs go up a bunch too on another
  machine.  I see that there's been some changes in 2.6.11.3 (or so?)
  wrt IPSEC and __xfrm_state_find_acq_byseq(), would that likely fix
  this problem?  I don't tend to use /unique:x but rather /require; in
  my policies, would changing that fix this?  I had originally been
  using a /24 for my transport policy and thought changing that to be a
  bunch of /32 policies for the specific machines I'm talking to would
  help- it didn't.

  Occationally (generally when I first get ipsec going between a couple
  machines) I see pmtu problems which kill that ssh, but after that it
  works.  Not a big deal but I see alot of MTU discussion and patches,
  is that expected to be in 2.6.12?

  	Thanks for any help,

		Stephen
