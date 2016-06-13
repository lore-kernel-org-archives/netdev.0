From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH 0/2] register-field manipulation macros
Date: Mon, 13 Jun 2016 14:29:52 +0100
Message-ID: <1465824594-29662-1-git-send-email-jakub.kicinski@netronome.com>
Cc: hannes@stressinduktion.org, nbd@nbd.name,
	linux-kernel@vger.kernel.org, kvalo@codeaurora.org,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

This set moves to a global header file macros which I find
very useful and worth popularising.  The basic problem is
that since C bitfields are not very dependable accessing
subfields of registers becomes slightly inconvenient.
It is nice to have the necessary mask and shift operations
wrapped in a macro.  It is also nice to have that macro
compute the shift amount based on the mask automatically.

My implementation follows what Felix Fietkau has done in
mt76.  Hannes Frederic Sowa suggested more use of standard
Linux/GCC functions.  Since the RFC I've also added a 
compile-time check to validate that the value passed to
setters fits in the mask.

I attempted the use of static inlines instead of macros
but it makes GCC < 6.0 barf at the BUILD_BUG_ON()s.
I also noticed that forcing arguments to be u32 for inlines
makes the compiler use 32bit arithmetic where it could
get away with 64bit before (on 64bit machines, obviously).
That's a potential performance concern but probably not
a very practical one today.  Apart from looking "cleaner"
static inlines would have the advantage that we could #undef
the auxiliary macros at the end of the header.

Please review and advise on improvements.

If accepted I think would be best to push this through
Kalle's tree, since the only existing user is in
drivers/net/wireless/.

Jakub Kicinski (2):
  add basic register-field manipulation macros
  mt7601u: use linux/bitfield.h

 drivers/net/wireless/mediatek/mt7601u/dma.h     |  2 -
 drivers/net/wireless/mediatek/mt7601u/mt7601u.h |  5 +-
 drivers/net/wireless/mediatek/mt7601u/util.h    | 77 -------------------------
 include/linux/bitfield.h                        | 58 +++++++++++++++++++
 include/linux/log2.h                            |  6 ++
 5 files changed, 68 insertions(+), 80 deletions(-)
 delete mode 100644 drivers/net/wireless/mediatek/mt7601u/util.h
 create mode 100644 include/linux/bitfield.h

-- 
1.9.1
