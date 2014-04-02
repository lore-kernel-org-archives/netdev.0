From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH regression] net: phy: fix initialization (config_init)
 for Marvel 88E1116R PHYs
Date: Thu, 03 Apr 2014 00:30:17 +0200
Message-ID: <533C8F79.2030707@gmail.com>
References: <1396396559-6971-1-git-send-email-holler@ahsoftware.de> <CAGVrzcZd9tBtcTY_2PRHVb9kJAjVHqn+EubUy4NGL66M_UuCDg@mail.gmail.com> <533BD3CD.1010905@ahsoftware.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>,
	stable <stable@vger.kernel.org>
To: Alexander Holler <holler@ahsoftware.de>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <533BD3CD.1010905@ahsoftware.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/02/2014 11:09 AM, Alexander Holler wrote:
> Am 02.04.2014 02:57, schrieb Florian Fainelli:
>> Could you verify the following two things before your patch gets merged:
>>
>> - how long does it take for your PHY to clear the BMCR_RESET bit, is
>> it more than the allowed time out in
>> drivers/net/phy/phy_device.c::phy_poll_reset
>> - is your PHY powered down (check BMCR_PWRDOWN), if that is the case,
>> we might be hitting some corner case where toggling BMCR_RESET will
>> power it on, but at the expense of waiting longer
> 
> I've  done two tests with pr_info before and after the two resets in
> m88e1116r_config_init:
> 

[...]

> with mdelay (the value after reset is what contains MII_BMCR):
> 
> -----------------------
> dmesg | grep -A1 -B1  AHO
> [    1.090072] mv643xx_eth: MV-643xx 10/100/1000 ethernet driver version
> 1.4
> [    1.175888] AHO: before first reset
> [    1.678806] AHO: after first reset 0x0
> [    1.683281] AHO: before second reset
> [    2.186288] AHO: after second reset 0x0
> [    2.191010] mv643xx_eth_port mv643xx_eth_port.0 eth0: port 0 with MAC
> address xx
> -- 
> [    2.426349] netpoll: netconsole: device eth0 not up yet, forcing it
> [    2.505917] AHO: before first reset
> [    2.605824] usb 1-1: new high-speed USB device number 2 using orion-ehci
> -- 
> [    2.829987] hub 1-1:1.0: 4 ports detected
> [    3.044502] AHO: after first reset 0x0

If the above hex at the end is BMCR..

> [    3.049133] AHO: before second reset
> [    3.126110] usb 1-1.1: new high-speed USB device number 3 using
> orion-ehci
> -- 
> [    3.526107] usb 1-1.3: device descriptor read/64, error -32
> [    3.614264] AHO: after second reset 0x0
> [    3.618708] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
> -- 
> [   21.335730] Adding 2996116k swap on /dev/sda3.  Priority:-1 extents:1
> across:2996116k
> [   28.195942] AHO: before first reset
> [   28.696270] AHO: after first reset 0x800

.. have you noticed that your PHY enters POWERDOWN here?

Sebastian

> [   28.696958] AHO: before second reset
> [   29.197354] AHO: after second reset 0x800
> [  111.612263] RPC: Registered named UNIX socket transport module.
> -----------------------
