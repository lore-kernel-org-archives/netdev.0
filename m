From: Gustavo Padovan <gustavo@padovan.org>
Subject: Re: pull request: bluetooth 2012-05-04
Date: Sat, 12 May 2012 16:09:00 -0300
Message-ID: <20120512190900.GA15956@joana>
References: <20120505001243.GC23728@joana>
 <20120508070211.GB11843@joana>
 <20120511201620.GD7620@joana>
 <20120512182227.GA30574@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-wireless@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120512182227.GA30574@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

* John W. Linville <linville@tuxdriver.com> [2012-05-12 14:22:27 -0400]:

> On Fri, May 11, 2012 at 05:16:20PM -0300, Gustavo Padovan wrote:
> > Hi Dave,
> > 
> > I couldn't get this pull by John this week, he's been unresponsive.
> > We would love to see this code in the 3.4 kernel (not sure if this would be
> > possible if Linus do not release the -rc7, there are important fixes 
> > in the pull request, such as a fix to a regression that was breaking bluetooth
> > keyboards.
> > 
> > Please let me know if you have any problems with this! I checked this code for
> > coding style issues too. Thanks.
> 
> Well, I do apologize for my lack of responsiveness.  My employer saw
> fit to have me (figuratively) locked in a room with no email access all
> week, with me getting home rather late in the evenings and returning
> early each morning.  I would have liked to have stayed awake for
> hours each night catching-up, but I just didn't have the strength. :-(
> 
> With that said, I'm not at all sure that this batch of fixes is
> appropriate for this late in the release cycle.  Normally at this
> point I would expect to see "regression cause by commit 1234" or
> "this common action results in this crash", all fixed by one-liners
> wherever possible.  This batch is more like "causes some problems",
> or "needs to be different" -- neither of which sound urgent enough
> to be worth requesting delays in Linus's release schedule.


In my point of view there are two commits there that are really necessary:

Gustavo Padovan (2):
      Bluetooth: report the right security level in getsockopt

Johan Hedberg (2):
      Bluetooth: mgmt: Fix device_connected sending order

They fix a userspace breakage caused by:

Author: Marcel Holtmann <marcel@holtmann.org>
Date:   Mon Feb 20 21:24:37 2012 +0100

    Bluetooth: Always enable management interface
    
    The management interface API has reached stable version 1.0 and thus
    it can now be always enabled. All future changes will be made backwards
    compatible.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
    Signed-off-by: Johan Hedberg <johan.hedberg@intel.com>


This cause no crash, but it make bluetooth keyboards stop to work with Linux.
This a serious breakage IMO. I really would like to see at least these two
patches in. The other fixes can wait.
 
	Gustavo

---

The following changes since commit 985140369be1e886754d8ac0375dd64e4f727311:

  Add Foxconn / Hon Hai IDs for btusb module (2012-04-24 11:38:41 -0300)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth for-upstream

for you to fetch changes up to 3ca67a07a20880c78bfce52017956c1472db69ff:

  Bluetooth: mgmt: Fix device_connected sending order (2012-05-12 16:02:06 -0300)

----------------------------------------------------------------
Gustavo Padovan (1):
      Bluetooth: notify userspace of security level change

Johan Hedberg (1):
      Bluetooth: mgmt: Fix device_connected sending order

 include/net/bluetooth/bluetooth.h |    1 +
 net/bluetooth/af_bluetooth.c      |    2 +-
 net/bluetooth/hci_core.c          |    8 ++++++++
 net/bluetooth/hci_event.c         |   11 +++++++++--
 net/bluetooth/l2cap_core.c        |    5 +++++
 net/bluetooth/l2cap_sock.c        |   15 ++++++++++-----
 6 files changed, 34 insertions(+), 8 deletions(-)
