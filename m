From: Tyler Hicks <tyhicks@canonical.com>
Subject: [PATCH 0/2] Quiet noisy LSM denial when accessing net sysctl
Date: Fri,  6 May 2016 18:04:12 -0500
Message-ID: <1462575854-4301-1-git-send-email-tyhicks@canonical.com>
Cc: Serge Hallyn <serge.hallyn@canonical.com>,
	"David S . Miller" <davem@davemloft.net>
To: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

This pair of patches does away with what I believe is a useless denial
audit message when a privileged process initially accesses a net sysctl.

The bug was first discovered when running Go applications under AppArmor
confinement. It can be triggered like so:

  $ echo "profile test { file, }" | sudo apparmor_parser -rq

Once the profile is loaded, invoke Go as root under confinement:

  $ sudo aa-exec -p test -- go version
  go version go1.6.1 linux/amd64

Here's the denial:

  audit: type=1400 audit(1462575436.832:29): apparmor="DENIED" operation="capable" profile="test" pid=1157 comm="go" capability=12  capname="net_admin"

The reproducer in minimal form is:

  $ sudo aa-exec -p test -- cat /proc/sys/net/core/somaxconn
  128

The denial:

  audit: type=1400 audit(1462575670.000:29): apparmor="DENIED" operation="capable" profile="test" pid=1161 comm="cat" capability=12  capname="net_admin"

Thanks!

Tyler

