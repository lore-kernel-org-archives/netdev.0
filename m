From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 08/18] net: dsa: mv88e6xxx: move generic VTU GetNext
Date: Fri, 28 Apr 2017 11:07:08 -0400
Message-ID: <87wpa47eqr.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com> <20170426155336.5937-9-vivien.didelot@savoirfairelinux.com> <20170427185912.GK17364@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:46474 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932243AbdD1PIv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 11:08:51 -0400
In-Reply-To: <20170427185912.GK17364@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> +	/* Write the VID to iterate from only once */
>> +	if (!entry->valid) {
>> +		err = mv88e6xxx_g1_vtu_vid_write(chip, entry);
>> +		if (err)
>> +			return err;
>> +	}
>
> Please could you add a bigger comment. It is not clear why you write
> it, when it is invalid. That just seems wrong, and needs a good
> comment to explain why it is correct, more than what you currently
> have as a comment.

This trick could indeed benefit a better explanation. The reason for it
is that I used the same comment as the ATU GetNext implementation, i.e.:

    /* Write the MAC address to iterate from only once */
    if (entry->state == GLOBAL_ATU_DATA_STATE_UNUSED) {
        err = mv88e6xxx_g1_atu_mac_write(chip, entry);
        if (err)
            return err;
    }

I suggest me sending a future patch to improve the comments of both
GetNext (ATU and VTU) implementations at the same time later.

Thanks,

        Vivien
