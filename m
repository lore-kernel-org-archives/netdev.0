From: shemminger@osdl.org
Subject: Re: [PATCH] (7/23) sk98: basic ethtool support
Date: Fri, 12 Nov 2004 20:39:48 -0800 (PST)
Message-ID: <60128.63.170.215.71.1100320788.squirrel@www.osdl.org>
References: <4192C60A.1050205@designassembly.de>
    <20041111154225.5cf85567@zqx3.pdx.osdl.net>
    <20041111155503.6e0349b8@zqx3.pdx.osdl.net>
    <20041112162904.GB7066@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "Stephen Hemminger" <shemminger@osdl.org>,
        "Jeff Garzik" <jgarzik@pobox.com>,
        "Michael Heyse" <mhk@designassembly.de>,
        "Mirko Lindner" <mlindner@syskonnect.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20041112162904.GB7066@infradead.org>
To: "Christoph Hellwig" <hch@infradead.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> On Thu, Nov 11, 2004 at 03:55:03PM -0800, Stephen Hemminger wrote:
>> The basic stuff comes from the newer code from SysKonnect, but I redid
>> it using ethtool_ops and a cleaner way of doing the stats (from e100)
>
>
>> +/*****************************************************************************
>> + *
>> + * 	getSettings - retrieves the current settings of the selected
>> adapter
>> + *
>> + * Description:
>> + *	The current configuration of the selected adapter is returned.
>> + *	This configuration involves a)speed, b)duplex and c)autoneg plus
>> + *	a number of other variables.
>> + *
>> + * Returns:    always 0
>> + *
>> + */
>
> Please use normal kernel-doc function documentation.

That was SysKonnect's format, personally I would rather no
comment because this isn't an API for any external usage and
is obvious.

>
>> +static int getSettings(struct net_device *dev, struct ethtool_cmd
>> *ecmd)
>
> And avoid studlyCaps.  Also an sk98lin prefix even on private function
> helps avoiding nameclashes for the generic names (and in the debugger
> or oopses)

I'll just change them to normal kernel format (ie get_settings).
But no, putting prefix's on local obvious functions is a waste.

>> +{
>> +	const DEV_NET *pNet = netdev_priv(dev);
>
> please always use struct net_device instead of strange typedefs for it.

DEV_NET is one of their typedef's (for the driver private data). I prefer
to change them last after all the other patches. Don't want some files
using 'struct s_Devnet' and others using 'DEV_NET', that would be
more confusing.  Eventually DEV_NET will be replaced by something
more descriptive 'struct sk98_port' and AC will be 'struct sk8_board'
