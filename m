From: Valentine Barshak <vbarshak@ru.mvista.com>
Subject: Re: [PATCH] USB: net: Fix asix read transfer
 buffer allocations.
Date: Mon, 22 Oct 2007 23:22:59 +0400
Message-ID: <471CF893.3050605@ru.mvista.com>
References: <20071022155053.GA28526@ru.mvista.com>
	<200710221929.04035.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb-devel@lists.sourceforge.net
To: Oliver Neukum <oliver@neukum.org>
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
In-Reply-To: <200710221929.04035.oliver@neukum.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-usb-devel>
List-Post: <mailto:linux-usb-devel@lists.sourceforge.net>
List-Help: <mailto:linux-usb-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux-usb-devel-bounces@lists.sourceforge.net
Errors-To: linux-usb-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Oliver Neukum wrote:
> Am Montag 22 Oktober 2007 schrieb Valentine Barshak:
>>  static int asix_mdio_read(struct net_device *netdev, int phy_id, int loc)
>>  {
>>         struct usbnet *dev = netdev_priv(netdev);
>> +       void *buf;
>>         u16 res;
>>  
>>         mutex_lock(&dev->phy_mutex);
>>         asix_set_sw_mii(dev);
>> +
>> +       buf = kmalloc(2, GFP_KERNEL);
> 
> This is done under lock. Can you allocate the buffer once and reuse it?
> 
> 	Regards
> 		Oliver
> 
I think we can use 2 bytes of the usbnet data buffer for this.
I'll submit a new patch soon.
Thanks,
Valentine.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
