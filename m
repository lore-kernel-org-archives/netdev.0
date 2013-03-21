From: Frank Rowand <frank.rowand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [BUG] bisected: PandaBoard smsc95xx ethernet driver error from
 USB timeout
Date: Thu, 21 Mar 2013 13:05:02 -0700
Message-ID: <514B67EE.8030404@am.sony.com>
References: <Pine.LNX.4.44L0.1303211037070.1899-100000@iolanthe.rowland.org>
Reply-To: <frank.rowand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Rowand, Frank" <Frank_Rowand-FuZ7eS5WsvxBDgjK7y7TUQ@public.gmane.org>,
	"gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org" <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"balbi-l0cyMroinI0@public.gmane.org" <balbi-l0cyMroinI0@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"steve.glendinning-sdUf+H5yV5I@public.gmane.org" <steve.glendinning-sdUf+H5yV5I@public.gmane.org>
To: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.44L0.1303211037070.1899-100000-IYeN2dnnYyZXsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/21/13 07:41, Alan Stern wrote:
> On Wed, 20 Mar 2013, Frank Rowand wrote:
> 
>> Hi All,
>>
>> Not quite sure quite where the problem is (USB, OMAP, smsc95xx driver, other???),
>> so casting the nets wide...
>>
>> The PandaBoard frequently fails to boot with an eth0 error when mounting
>> the root file system via NFS (ethernet driver fails due to a USB timeout;
>> no ethernet means NFS won't work).  A typical set of error messages is:
>>
>> [    3.264373] smsc95xx 1-1.1:1.0: usb_probe_interface
>> [    3.269500] smsc95xx 1-1.1:1.0: usb_probe_interface - got id
>> [    3.275543] smsc95xx v1.0.4
>> [    8.078674] smsc95xx 1-1.1:1.0: eth0: register 'smsc95xx' at usb-ehci-omap.0-1.1, smsc95xx USB 2.0 Ethernet, 82:b9:1d:fa:67:0d
>> [    8.091003] hub 1-1:1.0: state 7 ports 5 chg 0000 evt 0002
>> [   13.509918] usb 1-1.1: swapper/0 timed out on ep0out len=0/4
>> [   13.515869] smsc95xx 1-1.1:1.0: eth0: Failed to write register index 0x00000108
>> [   13.523559] smsc95xx 1-1.1:1.0: eth0: Failed to write ADDRL: -110
>> [   13.529998] IP-Config: Failed to open eth0
>>
>> I have bisected this to:
>>
>>   commit 18aafe64d75d0e27dae206cacf4171e4e485d285
>>   Author: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
>>   Date:   Wed Jul 11 11:23:04 2012 -0400
>>
>>      USB: EHCI: use hrtimer for the I/O watchdog
> 
> I don't understand how that commit could cause a timeout unless there 
> are at least two other bugs present in your system.

Yes, I would not be at all surprised if this commit merely exposes a
problem in other code.  That is why I included so many different people
and subsystems on the email distribution list.

< snip >

-Frank

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
