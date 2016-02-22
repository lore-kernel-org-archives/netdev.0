From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCHv2 00/10] RFKill airplane-mode indicator
Date: Mon, 22 Feb 2016 11:36:31 -0500
Message-ID: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Darren Hart <dvhart-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	platform-driver-x86-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-6IF/jdPJHihWk0Htik3J/w@public.gmane.org,
	=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?= <jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This series implements an airplane-mode indicator LED trigger, which ca=
n be
used by platform drivers. The default policy have have airplane-mode se=
t when
all the radios known by RFKill are OFF, and unset otherwise. This polic=
y can be
overwritten by one single userspace application at a time using the ope=
rations
_AIRPLANE_MODE_INDICATOR_ACQUIRE and _AIRPLANE_MODE_INDICATOR_CHANGE. W=
hen the
airplane-mode indicator state changes, userspace gets notifications thr=
ough the
RFKill control misc device (/dev/rfkill).

The series also contains a few general fixes and improvements to the su=
bsystem.

Additionally, I have a couple of patches to have this feature supported=
 by the
userspace tool 'rfkill' [1]. Should I use a different subject prefix to=
 help
separate those from kernel patches in linux-wireless?

[1] https://wireless.wiki.kernel.org/en/users/documentation/rfkill

Jo=C3=A3o Paulo Rechi Vita (10):
  rfkill: Improve documentation language
  rfkill: Remove extra blank line
  rfkill: Point to the correct deprecated doc location
  rfkill: Move "state" sysfs file back to stable
  rfkill: Factor rfkill_global_states[].cur assignments
  rfkill: Add documentation about LED triggers
  rfkill: Create "rfkill-airplane-mode" LED trigger
  rfkill: Use switch to demux userspace operations
  rfkill: Userspace control for airplane mode
  rfkill: Notify userspace of airplane-mode state changes

 Documentation/ABI/obsolete/sysfs-class-rfkill |  20 ----
 Documentation/ABI/stable/sysfs-class-rfkill   |  27 ++++-
 Documentation/rfkill.txt                      |  17 +++
 include/uapi/linux/rfkill.h                   |   6 +
 net/rfkill/core.c                             | 162 ++++++++++++++++++=
++------
 5 files changed, 173 insertions(+), 59 deletions(-)
 delete mode 100644 Documentation/ABI/obsolete/sysfs-class-rfkill

--=20
2.5.0
