From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 0/4] delete useless variable
Date: Mon, 13 Jan 2014 17:17:23 +0100
Message-ID: <1389629847-5330-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, linux-fbdev@vger.kernel.org,
 kernel-janitors@vger.kernel.org, linux-wireless@vger.kernel.org,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: brcm80211-dev-list@broadcom.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

These patches delete declarations and initializations of variables that are
only assigned to constants but never used otherwise.

The complete semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r exists@
type T;
identifier i,i2;
position p;
@@

T i@p;
... 
i = i2

@@
type r.T;
identifier r.i;
constant c;
position p != r.p;
@@

-T i@p;
<... when != i
-i = c;
...>
// </smpl>
