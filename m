From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Network drivers that don't suspend on interface down
Date: Wed, 20 Dec 2006 23:08:47 -0800
Message-ID: <458A32FF.1010700@osdl.org>
References: <200612202125.10865.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Matthew Garrett <mjg59@srcf.ucam.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422786AbWLUHKx@vger.kernel.org>
To: David Brownell <david-b@pacbell.net>
In-Reply-To: <200612202125.10865.david-b@pacbell.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Brownell wrote:
> Hmm, this reminds me of a thread from last summer, following up on
> some PM discussions at OLS.  Thread "Runtime power management for
> network interfaces", at the end of July.
>
>
>   
>> 2) Network device infrastructure should make it easier for devices:
>>     bring interface down on suspend and bring it up after resume
>>     (if it was running when suspended). This would allow many devices to
>>     have no suspend/resume hook; except those that have some better power
>>     control over hardware.
>>     
>
> The _intent_ of the class suspend() and resume() methods is to let
> infrastructure (the network stack was explicitly mentioned!) handle
> pretty much everything except putting the hardware in low power
> modes ... which last step might, for PCI devices at least, most
> naturally be done in suspend_late().  That way it'd be decoupled
> cleanly from anything else.
>   
The class methods don't work right for that because the physical class 
(PCI) gets
called before the virtual class  (network devices).

> Now, I recently tried refreshing a patch that used those class
> suspend() and resume() methods, and for some reason they're not
> getting called.  I believe they used to get called, although it's
> true their parameter wasn't very useful ... it was called with the
> underlying device, not the class_device holding state that the
> class driver manages.
>
> I just wanted to point out that yes, this ground has been covered
> before, with some agreement on that approach.  It'd be good to see
> it pursued.  :)
>
> - Dave
>
>   
