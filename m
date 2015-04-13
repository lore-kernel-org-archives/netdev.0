From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH resend] Renesas Ethernet AVB driver
Date: Mon, 13 Apr 2015 23:34:17 +0300
Message-ID: <552C2849.2080503@cogentembedded.com>
References: <2926619.fiYHPz1IBk@wasted.cogentembedded.com> <1427982999.18722.35.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: Ben Hutchings <ben.hutchings@codethink.co.uk>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1427982999.18722.35.camel@xylophone.i.decadent.org.uk>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 04/02/2015 04:56 PM, Ben Hutchings wrote:

> This driver looks somewhat similar to sh-eth, but lacks some of the
> recent bug fixes made to that.  At least commit 283e38db65e7 ("sh_eth:
> Fix serialisation of interrupt disable with interrupt & NAPI handler")
> appears to be applicable, but there are probably others.

    I suspect this issue applies to many drivers...
    I couldn't reproduce the bug that patch was fixing, so left this fix out 
for the time being. Others cases were fixed (if applicable).

> One feature request:

> On Sat, 2015-03-28 at 02:13 +0300, Sergei Shtylyov wrote:
> [...]
>> +/* ioctl to device function */
>> +static int ravb_do_ioctl(struct net_device *ndev, struct ifreq *req, int cmd)
>> +{
>> +	struct ravb_private *priv = netdev_priv(ndev);
>> +	struct phy_device *phydev = priv->phydev;
>> +
>> +	if (!netif_running(ndev))
>> +		return -EINVAL;
>> +
>> +	if (!phydev)
>> +		return -ENODEV;
>> +
>> +	if (cmd == SIOCSHWTSTAMP)
>> +		return ravb_hwtstamp_ioctl(ndev, req, cmd);
> [...]

> The driver should also handle SIOCGHWTSTAMP.

    Done.

> Ben.

WBR, Sergei

