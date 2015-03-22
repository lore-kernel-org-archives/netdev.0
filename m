From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 08/18] net: dsa: mv88e6xxx: Add Hardware bridging support
Date: Sun, 22 Mar 2015 21:59:57 +0100
Message-ID: <20150322205957.GF15025@lunn.ch>
References: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
 <1426952815-4642-9-git-send-email-linux@roeck-us.net>
 <20150322200600.GD15025@lunn.ch>
 <550F29FD.7050509@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <550F29FD.7050509@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 22, 2015 at 01:45:49PM -0700, Guenter Roeck wrote:
> On 03/22/2015 01:06 PM, Andrew Lunn wrote:
> >Hi Guenter
> >
> >>+static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, int fid, u16 cmd)
> >>+{
> >>+	int ret;
> >>+
> >>+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x01, fid);
> >>+	if (ret < 0)
> >>+		return ret;
> >
> >Please could you check this. I think register 0x01 here is wrong. I
> >think you want 0x0b, the ATU Operations register?
> >
> The ATU operation is initiated below (and does write to register 0x0b).
> Register 0x01 is FID[11..0] for ATU, which is what we want to write here.

http://lxr.free-electrons.com/source/drivers/net/dsa/mv88e6xxx.c#L156

156 int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr)
157 {
158         REG_WRITE(REG_GLOBAL, 0x01, (addr[0] << 8) | addr[1]);
159         REG_WRITE(REG_GLOBAL, 0x02, (addr[2] << 8) | addr[3]);
160         REG_WRITE(REG_GLOBAL, 0x03, (addr[4] << 8) | addr[5]);
161 
162         return 0;
163 }

So maybe the meaning of these registers has changed between different
versions of the chips? Only 6131 uses mv88e6xxx_set_addr_direct, all
the others use indirect method. So maybe the 6131 is going to need
something different here in _mv88e6xxx_atu_cmd()?

	  Andrew
