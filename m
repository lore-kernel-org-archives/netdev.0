From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Fix /proc/net/arp for AX.25
Date: Mon, 13 Feb 2017 22:15:51 -0500 (EST)
Message-ID: <20170213.221551.904691736246648194.davem@davemloft.net>
References: <20170210233857.GA13996@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thomas@osterried.de,
        linux-hams@vger.kernel.org
To: ralf@linux-mips.org
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20170210233857.GA13996@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Sat, 11 Feb 2017 00:38:57 +0100

> When sending ARP requests over AX.25 links the hwaddress in the neighbour
> cache are not getting initialized.  For such an incomplete arp entry
> ax2asc2 will generate an empty string resulting in /proc/net/arp output
> like the following:
> 
> $ cat /proc/net/arp
> IP address       HW type     Flags       HW address            Mask     Device
> 192.168.122.1    0x1         0x2         52:54:00:00:5d:5f     *        ens3
> 172.20.1.99      0x3         0x0              *        bpq0
> 
> The missing field will confuse the procfs parsing of arp(8) resulting in
> incorrect output for the device such as the following:
> 
> $ arp
> Address                  HWtype  HWaddress           Flags Mask            Iface
> gateway                  ether   52:54:00:00:5d:5f   C                     ens3
> 172.20.1.99                      (incomplete)                              ens3
> 
> This changes the content of /proc/net/arp to:
> 
> $ cat /proc/net/arp
> IP address       HW type     Flags       HW address            Mask     Device
> 172.20.1.99      0x3         0x0         *                     *        bpq0
> 192.168.122.1    0x1         0x2         52:54:00:00:5d:5f     *        ens3
> 
> To do so it change ax2asc to put the string "*" in buf for a NULL address
> argument.  Finally the HW address field is left aligned in a 17 character
> field (the length of an ethernet HW address in the usual hex notation) for
> readability.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied, thanks Ralf.
