From: James Ketrenos <jketreno@linux.intel.com>
Subject: Re: ipw2100: firmware problem
Date: Thu, 09 Jun 2005 16:01:30 -0500
Message-ID: <42A8AE2A.4080104@linux.intel.com>
References: <200506090909.55889.vda@ilport.com.ua>	<20050608.231657.59660080.davem@davemloft.net>	<20050609104205.GD3169@elf.ucw.cz> <20050609.125324.88476545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: pavel@ucw.cz, vda@ilport.com.ua, abonilla@linuxwireless.org,
	jgarzik@pobox.com, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org, ipw2100-admin@linux.intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262466AbVFIVCm@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050609.125324.88476545.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>From: Pavel Machek <pavel@ucw.cz>
>Date: Thu, 9 Jun 2005 12:42:05 +0200
>
>  
>
>>I'm not saying it should not work automagically. But it is wrong to
>>start transmitting on wireless as soon as kernel boots. It should stay
>>quiet in the radio until it is either told to talk or until interface
>>is upped.
>>    
>>
>
>I agree.
>
>There is a similar problem in the Acenic driver, it brings the
>link up and receives broadcast packets as soon as the driver
>is loaded.  Mostly this is because the driver inits the chip
>and registers the IRQ handler at probe time, whereas nearly
>every other driver does this at ->open() time.
>  
>
The ipw2100 originally postponed doing any initialization until open was
called.  The problem at that time was that distributions were crafted to
rely on link detection (I believe via ethtoolop's get_link) before they
would bring the interface up.

With a wireless device, you don't have link until you are associated... 
chicken and egg.  The solution was to move initialization and
association to the probe.

I don't know if all the distributions have moved away from this model. 
If they have and the devices are brought up regardless of link, then
going back to delaying radio initialization until the open() is called
is workable. 

James
