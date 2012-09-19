From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 0/6] xfrm_user info leaks
Date: Wed, 19 Sep 2012 23:33:37 +0200
Message-ID: <1348090423-32665-1-git-send-email-minipli@googlemail.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

the following series fixes various info leaks in the xfrm netlink
interface. As always, a test case can be supplied on request.

Patches 1 to 5 are probably material for stable, too. Patch 6 is just a
minor optimization I stumbled across while auditing the code.

Please apply!

P.S.: What's still missing IMHO, is some upper limit for the ESN replay
window size to prevent malicious users from making the kernel allocate
huge states. One could not retrieve those via netlink anyway (as the
current code allocates just a single page for the state dump). Maybe 4k
is a sane default upper limit for the replay window size. But I'll leave
implementing this to someone else. ;)


Mathias Krause (6):
  xfrm_user: fix info leak in copy_to_user_auth()
  xfrm_user: fix info leak in copy_to_user_state()
  xfrm_user: fix info leak in copy_to_user_policy()
  xfrm_user: fix info leak in copy_to_user_tmpl()
  xfrm_user: ensure user supplied esn replay window is valid
  xfrm_user: don't copy esn replay window twice for new states

 net/xfrm/xfrm_user.c |   41 ++++++++++++++++++++++++++++++-----------
 1 file changed, 30 insertions(+), 11 deletions(-)

-- 
1.7.10.4
