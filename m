From: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
Subject: [RFC PATCH 00/17] CALIPSO implementation
Date: Tue, 22 Dec 2015 11:46:36 +0000
Message-ID: <1450784813-18304-1-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Return-path: <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Post: <mailto:selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Help: <mailto:selinux-request-+05T5uksL2qpZYMLLGbcSA@public.gmane.org?subject=help>
Errors-To: selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Sender: "Selinux" <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: netdev.vger.kernel.org

This patch series implements RFC 5570 - Common Architecture Label IPv6
Security Option (CALIPSO).  Its goal is to set MLS sensitivity labels
on IPv6 packets using a hop-by-hop option.  CALIPSO very similar to
its IPv4 cousin CIPSO and much of this series is based on that code.

Most of this series involves adding support to NetLabel and adding a
CALIPSO module within IPv6, and as such is fairly self-contained.
There are however a few places where I've needed to add things to the
core networking stack, so I'd be particularly interested in hearing
comments about these:

[PATCH 08/17] ipv6: Add ipv6_renew_options_kern() that accepts a kernel mem pointer.
  Hopefully not too controversial - adds a kernel memory version of
  ipv6_renew_options()

[PATCH 12/17] ipv6: Allow request socks to contain IPv6 options.
  We need a way to set the IPv6 options on request sockets, just like
  we do for IPv4.  This is so that the LSM can ensure the SYN-ACK is
  correctly labelled.

The series is based off v4.4-rc6.

Thoughts about these and any of the other patches are most welcome.

If anybody actually wants to play with this, then you'll need some patches
to netlabel-tools that are currently available on the 'calipso' branch at:
https://github.com/hdmdavies/netlabel_tools.git

Thanks to Paul Moore for his guidance in getting this far.

Huw.
_______________________________________________
Selinux mailing list
Selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
To unsubscribe, send email to Selinux-leave-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
To get help, send an email containing "help" to Selinux-request-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
