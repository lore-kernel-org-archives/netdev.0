From: Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH 0/2] [BUG FIXES - 3.10.27] sit: More backports
Date: Tue, 28 Jan 2014 15:57:56 -0500
Message-ID: <20140128205756.074448668@goodmis.org>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	stable <stable@vger.kernel.org>,
	Clark Williams <williams@redhat.com>,
	"Luis Claudio R. Goncalves" <lclaudio@uudg.org>,
	John Kacur <jkacur@redhat.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At Red Hat we base our real-time kernel off of 3.10.27 and do lots of
stress testing on that kernel. This has discovered some bugs that we
can hit with the vanilla 3.10.27 kernel (no -rt patches applied).

I sent out a bug fix that can cause a crash with the current 3.10.27
when you add and then remove the sit module. That patch is obsoleted by
these patches, as that patch was not enough.

A previous patch that was backported:

  Upstream commit 205983c43700ac3a81e7625273a3fa83cd2759b5
  sit: allow to use rtnl ops on fb tunnel

Had a depenency on commit 5e6700b3bf98 ("sit: add support of x-netns")
which was not backported. The dependency was only on part of that
commit which is what I backported.

The other upstream commit 9434266f2c645d4fcf62a03a8e36ad8075e37943
sit: fix use after free of fb_tunnel_dev

fixes another bug we encountered, it also fixes the 3.10.27 bug
where removing the sit module cause the crash. This is the patch
that obsoletes my previous patch.

-- Steve


Steven Rostedt (Red Hat) (1):
      sit: Unregister sit devices with rtnl_link_ops

Willem de Bruijn (1):
      sit: fix use after free of fb_tunnel_dev

----
 net/ipv6/sit.c | 30 +++++++++++++++++++++++++-----
 1 file changed, 25 insertions(+), 5 deletions(-)
