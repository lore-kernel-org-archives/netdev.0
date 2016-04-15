From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 7/7] net: dsa: mv88e6xxx: drop switch id
Date: Fri, 15 Apr 2016 17:00:50 -0400
Message-ID: <87k2jya8ot.fsf@ketchup.mtl.sfl>
References: <1460744750-13896-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1460744750-13896-8-git-send-email-vivien.didelot@savoirfairelinux.com> <20160415193818.GE18523@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160415193818.GE18523@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

<snip>

>> -#define PORT_SWITCH_ID_6350	0x3710
>> -#define PORT_SWITCH_ID_6351	0x3750
>> -#define PORT_SWITCH_ID_6352	0x3520
>
> NACK
>
> These numbers are not obvious. PORT_SWITCH_ID_6320 i can
> understand. 0x1150 i have no idea what it is.

0x1150 is not even correct. That's the product number (bits 4:15) masked
with an assumed revision 0 (bits 0:3).

That leads to confusion and error, as seen in the patch 2/7.

These values are now only used in a device description table, where they
seem pretty understandable to me.

This header file is full of inconsistencies. We have masks, offsets,
shifts, shifted and unshifted values, just for the sake of hidding said
magic numbers, while an explicit comment in a function could do the job.

But OK if we really want them defined, I'll introduce 12-bit
PORT_SWITCH_ID_PROD_NUM_* before dropping the 16-bit PORT_SWITCH_ID_*.

Thanks,
Vivien
