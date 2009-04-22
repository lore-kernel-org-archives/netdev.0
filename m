From: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>
Subject: What makes a good fake MAC address?
Date: Thu, 23 Apr 2009 07:04:42 +0930
Message-ID: <20090423070442.1e643b5b.ipng@69706e6720323030352d30312d31340a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.mail.adnap.net.au ([203.6.132.66]:52700 "EHLO
	smtp2.mail.adnap.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753675AbZDVWDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 18:03:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Inaky,

(please CC me, I'm not on the list)

"The problem with using a zero mac address is that it confuses the
bridging software (and maybe others). I was wondering, what would be a
fake mac address we could put in there that is legal for this kind of
"faking"? [or the closest thing to legal?]"

Since you're from an organisation with an OUI allocation or two, I
think a real Intel one would be best. It then wouldn't be fake, and no
matter where it was exposed (host only, local network, or globally
e.g. in IPv6 node addresses), it would be guaranteed not to collide
with any other addresses (unless Intel make error an error in their own
OUI administration.) 

The other alternative would be locally assigned addresses i.e. those
out of the "0x02" range. There is a function in the kernel
(random_ether_addr()) to generate random ones which should minimise the
chances of collision with any others. If you don't have an OUI, then I
think they're a reasonable compromise. However, I don't think the
"global" linux kernel automatically assigning local addresses
completely fits with the idea of those addresses are only locally
significant and administered.

Don't do what Microsoft have done, and "globally" use a 0x02 address.
They've "stolen" some static 0x02 addresses for use with their high
availability software for Windows (0x02:01:01:01:01 is one of them
IIRC). I happened to discover it by assigning those addresses in a test
environment (i.e. *locally assigning* them), and then found Wireshark
displayed them as "belonging" to Microsoft. Fortunately I didn't happen
to have a MS HA environment, so I didn't break anything. If anybody has
ever had to troubleshoot duplicate MAC addresses, I'm sure they'd agree
that in the least MS should have randomised the addresses. Or
better yet, spent probably less than a millisecond's worth of their
revenue and got themselves an OUI, ensuring global uniqueness.

(Any chance Intel want to donate an OUI to the Linux kernel to used
instead of locally assigned addresses for things like dummy, tap and
etc. interfaces? From memory they're only US $1250 :-) )

Regards,
Mark.


