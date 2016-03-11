From: "Joseph Chang" <joseph_chang@davicom.com.tw>
Subject: RE: [PATCH 1/3] dm9601: enable EP3 interrupt
Date: Fri, 11 Mar 2016 18:47:32 +0800
Message-ID: <201603111049.u2BAnMHQ019860@mail.davicom.com.tw>
References: <87twkej8vx.fsf@dell.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="big5"
Content-Transfer-Encoding: 7bit
Cc: "'Peter Korsgaard'" <jacmet@sunsite.dk>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"'Joseph Chang'" <joseph_chang@davicom.com.tw>
To: "'Peter Korsgaard'" <peter@korsgaard.com>,
	"'Joseph CHANG'" <josright123@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87twkej8vx.fsf@dell.be.48ers.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After check more.
I think this is also to fix the bug to dm962x chip too. 

If keep no patch below:
 > +
 > +		/* Always return 8-bytes data to host per interrupt-interval */
 > +		dm_write_reg(dev, DM_USB_CTRL, USB_CTRL_EP3ACK);

 When attach dm962x to linux USB host, 
 The reg 'DM_USB_CTRL' get default value 0x00   
 This means the USB interrupt routine below,
   .status		= dm9601_status,
 will be called by events (they are: RX data found, TX complete, link change)
 Unfortunately, the link change CAN not work to trigger this event call.

 So I do
 > +		dm_write_reg(dev, DM_USB_CTRL, USB_CTRL_EP3ACK);

 That 
   .status		= dm9601_status,
  will be called by time interval.

 * ".status		= dm9601_status" is the way to tell the kernel new link
state,
  I can find it is bt 'usbnet_link_change( xx)' in ".status		=
dm9601_status".

Information:  
--------------------------------------------------------------------------------
--------
In my [PATCH 2/3], 

+#define	DM_EP3I_VAL	0x07
+	/* Render eeprom if need, WORD12 render, need 0x0007 */
+	dm_eeprom_render(dev, 12, DM_EP3I_VAL, 0xffff); }

It can determine the above time interval.

If user define
+#define	DM_EP3I_VAL	0x0f

The time interval will be around 1 second.
Note: Must reset the device once to get effect. 
--------------------------------------------------------------------------------
--------

Best Regards,
Joseph CHANG
System Application Engineering Division
Davicom Semiconductor, Inc.
No. 6 Li-Hsin 6th Rd., Science-Based Park,
Hsin-Chu, Taiwan.
Tel: 886-3-5798797 Ex 8534
Fax: 886-3-5646929
Web: http://www.davicom.com.tw


-----Original Message-----
From: Peter Korsgaard [mailto:jacmet@gmail.com] On Behalf Of Peter Korsgaard
Sent: Friday, March 11, 2016 5:55 AM
To: Joseph CHANG
Cc: Peter Korsgaard; netdev@vger.kernel.org; linux-usb@vger.kernel.org;
linux-kernel@vger.kernel.org; Joseph Chang
Subject: Re: [PATCH 1/3] dm9601: enable EP3 interrupt

>>>>> "Joseph" == Joseph CHANG <josright123@gmail.com> writes:

 > Enable chip's EP3 interrupt to get the link-up notify soon
 > immediately.

Sorry, what do you mean about 'soon immediately'?

 > +
 > +		/* Always return 8-bytes data to host per interrupt-interval */
 > +		dm_write_reg(dev, DM_USB_CTRL, USB_CTRL_EP3ACK);

Why would we want to do that instead of the current setup that afaik
only returns data when the link status changes?

-- 
Bye, Peter Korsgaard

-- 
This message has been scanned for viruses and
dangerous content by MailScanner, and is
believed to be clean.
