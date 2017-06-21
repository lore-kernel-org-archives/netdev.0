From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH net-next 0/2] sunvnet: add to ethtool data
Date: Wed, 21 Jun 2017 09:09:52 -0700
Message-ID: <1498061394-233018-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <sparclinux-owner@vger.kernel.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The first patch gets some driver-specific information available for
use by the LDom management utilities through the drvinfo service: the
lowlevel vio version into firmware-version field, and, most importantly,
the remote-mac address into the bus-info field.

When creating the LDoms and their network connections, there currently
isn't a good way to match the vif netdev to the client LDom that it
services.  By having the vif device print the remote-mac address from
the mdesc used to build the connection, the userland tools can correlate
which vif services which LDom.

There was some discussion about adding a 'remote-mac' element into the
/sys/class/net/<dev>/ model, but our thinking was that this might be
too specific to our devices and not fit well into the general model.
We're open to going back to that if others in the community think it
would be a better place for this data.

The second patch implements the get_settings service.  This might seem
moot as these primarily describe a hardware port connection which doesn't
make much sense in a virtualized network connection.  However, there are a
couple of userland LDom management tools that work better if this data is
filled out.  One specific example is that the /sys/class/net/<dev>/speed
attribute becomes readable.

Shannon Nelson (2):
  ldmvsw: add vio version and remote-mac to ethtool info
  sunvnet: implement basic ethtool get_settings

 drivers/net/ethernet/sun/ldmvsw.c         |    8 ++++++++
 drivers/net/ethernet/sun/sunvnet.c        |    1 +
 drivers/net/ethernet/sun/sunvnet_common.c |   11 +++++++++++
 drivers/net/ethernet/sun/sunvnet_common.h |    2 ++
 4 files changed, 22 insertions(+), 0 deletions(-)

