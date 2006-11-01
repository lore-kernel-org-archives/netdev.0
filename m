From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bcm43xx: fix unexpected LED control values in BCM4303 sprom
Date: Wed, 1 Nov 2006 12:27:22 +0100
Message-ID: <200611011227.23315.mb@bu3sch.de>
References: <4535AFC2.mail3S81JGSDJ@lwfinger.net> <20061101034936.GD9309@tuxdriver.com> <454823CC.9070808@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bcm43xx-dev@lists.berlios.de,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:56549
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1946794AbWKAL2j
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Nov 2006 06:28:39 -0500
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <454823CC.9070808@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 01 November 2006 05:34, Larry Finger wrote:
> John,
> 
> I had not responded to Michael's comments as I heard from another user with thousands of these 
> assertions in his logs, and I have been waiting for his sprom values and hoped to make a single 
> patch. It is good, however, that you pushed the patch upstream.
> 
> John W. Linville wrote:
> > On Wed, Oct 18, 2006 at 04:37:08PM +0200, Michael Buesch wrote:
> > 
> >>> @@ -257,7 +263,11 @@ void bcm43xx_leds_update(struct bcm43xx_
> >>>  			continue;
> >>>  #endif /* CONFIG_BCM43XX_DEBUG */
> >>>  		default:
> >>> -			assert(0);
> >>> +			if (bcm43xx_max_led_err) {
> >>> +				printkl(KERN_INFO PFX "Bad value in leds_update,"
> >>> +					" led->behaviour: 0x%x\n", led->behaviour);
> >>> +				--bcm43xx_max_led_err;
> >>> +			}
> >> I'd call this message bloat. ;) This is the first time the assertion
> >> triggers since it was added.
> >> You could instead remove the assert(), remove bcm43xx_max_led_err
> >> and use dprintkl instead of printkl.
> 
> I disagree with part of Michael's comments. I think we should have a dprintk, rather than dprintkl, 

An unlimited printk will hang the system on UP.

> so that we get printouts from all four of the sprom values.

I don't really think that dprintkl will prevent this.

> That way the user will be able to report  
> the numbers we need. As this would not limit the log entries and potentially generate thousands, 
> there should be a variable like bcm43xx_max_led_err to limit the number of log entries.
> 
> I will propose a new patch once I get the data for the second case. In the meantime, the patch you 
> have pushed upstream will fix the BCM4303 led assertions.

I still think it's a waste to add a variable, a printk and a long string which
all eat unswappable kernel memory for this cornercase.
I don't think it's really hard to tell somebody to execute "iwpriv ethX read_sprom"
when he reports the assert() is triggering.
You must communicate with him anyway to find out how the LEDs are mapped
to the physical descriptions on the device case.

-- 
Greetings Michael.
