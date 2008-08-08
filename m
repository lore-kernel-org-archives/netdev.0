From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v1 0/6] Labeled networking patches for 2.6.28
Date: Fri, 08 Aug 2008 16:52:45 -0400
Message-ID: <20080808203542.21077.37084.stgit@flek>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello everyone,

Attached is a short series of patches which fixup some issues with labeled
networking and add an important new feature: NetLabel address selectors.  The
addition of NetLabel address selectors is pretty cool because it now allows
you to toggle NetLabel based labeling by both the sending domain _and_ the
destination address.  For example, if you were to configure the SELinux
ping_t domain to send CIPSO labeled packets every packet sent by the ping_t
domain would be labeled, including DNS requests (very annoying!).

 # netlabelctl -p map list
 Configured NetLabel domain mappings (2)
  domain: "ping_t"
    protocol: CIPSOv4, DOI = 1
  domain: DEFAULT
    protocol: UNLABELED

This addition of address selectors now allows you to breakdown the single
domain configuration by destination address.  This allows you to specify
different labeling configuration within the ping_t domain.

 # netlabelctl -p map list
 Configured NetLabel domain mappings (2)
  domain: "ping_t"
    address: 192.168.0.78/32
     protocol: CIPSOv4, DOI = 1
    address: 0.0.0.0/0
     protocol: UNLABELED
  domain: DEFAULT
    protocol: UNLABELED

In the example above, only packets sent to 192.168.0.78 from the ping_t
domain will be labeled with a CIPSO label; everything else, i.e. 0.0.0.0/0,
is unlabeled.  You will also notice that the default mapping is still using
the traditional (one domain, one configuration) policy, this is because you
have the option to use the address selectors on a per-domain basis.

The patches below are still pretty rough, but they do work as a proof of
concept that functions without any regressions under simple testing.  I
would ask that you give the patches a quick review and let me know if you
see anything scary; patch #4 in particular makes me nervous because of the
IP header manipulation.  I'll send out instructions on how to configure
the new bits later but I wanted to get this out now so people could look
it over.

The patches are included in the lblnet-2.6_testing tree:
 * git://git.infradead.org/users/pcmoore/lblnet-2.6_testing

The matching userspace changes can be found in the netlabel_tools
"addrsel" branch:
 * http://netlabel.svn.sf.net/viewvc/netlabel/netlabel_tools/branches/addrsel

Thanks.

-- 
paul moore
linux @ hp
