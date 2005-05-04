From: "Michael Chan" <mchan@broadcom.com>
Subject: RE: Mystery packet killing tg3
Date: Tue, 3 May 2005 23:27:38 -0700
Message-ID: <B1508D50A0692F42B217C22C02D84972020F3EB2@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Stephen Hemminger" <shemminger@osdl.org>,
        "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

> Initially, it reproduced everytime link came up, we 
> reconfigured the VLAN to
> have a mirror port into a laptop to try and capture what was 
> happening, but when
> we did that the bootup problem went away. It was in the tg3_reset_hw
> during initial dev_open.
> 

During initial dev_open, the TG3_FLAG_INIT_COMPLETE flag is not set so
tg3_reset_hw() should not call tg3_abort_hw() where the stop_block calls are
made. So there should be no stop_block errors.

I think stop_block errors can only happen during dev_close, suspend, netdev
watchdog, or ethtool "set" calls.
