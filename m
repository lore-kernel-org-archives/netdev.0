From: "Michael Chan" <mchan@broadcom.com>
Subject: RE: tg3 access hangs on system shutdown with 2.6.11-rc5,
 tg3_stop_block timed out
Date: Mon, 28 Feb 2005 13:33:38 -0800
Message-ID: <B1508D50A0692F42B217C22C02D84972020F3DD2@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-class: urn:content-classes:message
To: "Olaf Hering" <olh@suse.de>, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> 
> my JS20 blades hang on system reboot with current Linus tree. 
> I think it started after rc3. Maybe this line in dmesg gives a hint:
> 
> tg3: tg3_stop_block timed out, ofs=4000 enable_bit=2
> 

Olaf,

This error message means that the memory arbiter cannot be disabled for some
reason. Looking at the code, tg3_abort_hw() will return -ENODEV and skip the
2 memset calls to zero out the hw_status and hw_stats memory. I don't believe
skipping the memset calls can cause a hang. After tg3_abort_hw(), the chip
should then be reset to a known state.

The 5704S changes in 2.6.11-rc4 are mainly related to serdes link-up and tx
signal. I don't see how those changes can cause a hang or the tg3_stop_block
error. The stack trace did not show any tg3 function calls. Can you narrow it
down further to a specific patch that is causing the problem?

Michael
