From: David Kimdon <david.kimdon@devicescape.com>
Subject: [take2 0/5] d80211: remove bitfields from include/net/d80211.h
Date: Wed, 18 Oct 2006 14:20:22 -0700
Message-ID: <20061018212022.GA9173@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:22991 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1422964AbWJRVUZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 17:20:25 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Continue d80211 bitfield removal.  In general, compilers have
difficulty generating efficient code for bitfields.  This patchset
removes all bitfields from include/net/d80211.h.

I converted the 1 bit bitfields into a bit in a u32/u16 or u8 flags
structure member.  Larger bitfields I converted into their
u8/u16/whatever equivalent.

This should be a no-op from a functionality standpoint.

All tests using gcc 4.1.2.

The size of structures where bitfields were removed is identical
patched and unpatched.  All object text size is either slightly
smaller after the patch, or unchanged (bss and data are all
unchanged).  With all d80211 drivers compiled in the patched vmlinux
is 928 bytes smaller.

Changes from take1:

Update rt2500usb.c and rt73usb.c drivers based on the new structures.

Changes from take0:

Update the patches to apply on top of the following patches:

d80211: remove unused Super AG definitions, purge comment
    (http://marc.theaimsgroup.com/?l=linux-netdev&m=116102409931269&w=2)
d80211: remove initialization of unused xr structure members
    (http://marc.theaimsgroup.com/?l=linux-netdev&m=116076811809305&w=4)
d80211: remove unused xr structure members, interface, etc.
    (http://marc.theaimsgroup.com/?l=linux-netdev&m=115989929600617&w=4)

For key_conf_bitfields.patch change the new flags member to u8 from u32.

For tx_control_bitfields.patch move the rts_cts_duration and retry_limit members
in ieee80211_tx_control to allow for smaller structure size and change the
flags member from u32 to u16. 

For tx_status_bitfields.patch, in
drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c and
drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c note that
ieee80211_tx_status is already zero'd, so the ack bit only needs to be
set, not cleared.

--
