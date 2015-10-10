From: Tillmann Heidsieck <theidsieck@leenox.de>
Subject: [PATCH 0/2] atm: iphase: Fix misleading indention and return -ENOMEM on error
Date: Sat, 10 Oct 2015 21:47:17 +0200
Message-ID: <1444506439-10414-1-git-send-email-theidsieck@leenox.de>
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tillmann Heidsieck <theidsieck@leenox.de>
To: Chas Williams <3chas3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OK here it goes ...

There are three non-indention specific smatch warnings in atm/iphase.c

drivers/atm/iphase.c:115 ia_enque_rtn_q() warn: returning -1 instead of -ENOMEM is sloppy
drivers/atm/iphase.c:148 ia_hack_tcq() warn: if();
drivers/atm/iphase.c:1178 rx_pkt() warn: curly braces intended?

this series fixes two of them. The if(); warning would require
restructuring the code to a larger extend. Beyond this there remains a
whooping number of > 2k checkpatch.pl warnings and errors each. Those
can be grouped into 

- Direct usage of printk()
- Style issues concerning operators
- Style issues concerning {}
- Indention with spaces, mixed tabs and spaces etc
- Trailing white-spaces

Generally I would not mind cleaning all this up for those who have to
make functional changes to the driver. However, I would like to know
from the maintainers if such an afford would be welcome or not.

Regards,
Tillmann Heidsieck


Tillmann Heidsieck (2):
  atm: iphase: return -ENOMEM instead of -1 in case of failed kmalloc()
  atm: iphase: fix misleading indention

 drivers/atm/iphase.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

-- 
2.6.1
