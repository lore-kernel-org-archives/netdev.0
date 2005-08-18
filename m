From: "Michael Chan" <mchan@broadcom.com>
Subject: RE: OK if tg3_get_eeprom_hw_cfg() reads SRAM?
Date: Thu, 18 Aug 2005 00:40:42 -0700
Message-ID: <B1508D50A0692F42B217C22C02D84972067F090E@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Grant Grundler" <iod00d@hp.com>, davem@davemloft.net,
        mchan@broadcom.hp.com.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Grant Grundler wrote:

> The comment before tg3_get_eeprom_hw_cfg() suggests tg3
> should ONLY be touching PCI cfg space until the NIC gets
> to D0 power state.

The comment is correct. In D3 power state, the chip will
not respond to MMIO. When I did that patch, I made very
sure that only config. cycles were used before switching
to D0.

> But tg3_get_eeprom_hw_cfg() is called before
> tg3_set_power_state(tp,0).

> Is it OK for tg3_get_eeprom_hw_cfg() to read
> NIC_SRAM_DATA_CFG?

Yes, NIC_SRAM_DATA_CFG is in memory space (as opposed to
register space) and we always use config. cycles to
read/write memory space. Please see tg3_read/write_mem().
