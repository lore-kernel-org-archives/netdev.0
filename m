From: <Mario_Limonciello@Dell.com>
Subject: RE: [PATCH] r8152: Add support for setting MAC to system's Auxiliary
 MAC address
Date: Thu, 2 Jun 2016 02:53:06 +0000
Message-ID: <cfff846f3ca34b6a889f07f971b27271@ausx13mpc124.AMER.DELL.COM>
References: <1464817844-27206-1-git-send-email-mario_limonciello@dell.com>
 <20160601230535.GA29279@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <hayeswang@realtek.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<pali.rohar@gmail.com>, <anthony.wong@canonical.com>
To: <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160601230535.GA29279@kroah.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > +static u8 amac_ascii_to_hex(int c)
> > +{
> > +	if (c <= 0x39)
> > +		return (u8)(c - 0x30);
> > +	else if (c <= 0x46)
> > +		return (u8)(c - 0x37);
> > +	return (u8)(c - 0x57);
> > +}
> 

Sorry forgot to address this.  

> We really don't have such a function somewhere in the kernel already?

There is a function in acpi/acpica/uthex.c that does this, but it doesn't seem to be used by anything outside of acpica so far.  Would it be OK style wise to 
#include " ../../acpi/acpica/acutils.h" from r8152.c?  

If not, then what is the proper thing to do here to re-use it from there?

> And why 'int', isn't "c" really a u8?

Yeah I guess u8 should be fine there, and avoid the casting then too.
