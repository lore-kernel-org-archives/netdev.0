From: Pavel Machek <pavel@suse.cz>
Subject: Re: [patch] workaround zd1201 interference problem
Date: Thu, 8 Jun 2006 09:13:08 +0200
Message-ID: <20060608071308.GA4086@elf.ucw.cz>
References: <20060607140045.GB1936@elf.ucw.cz> <20060607160828.0045e7f5@griffin.suse.cz> <20060607141536.GD1936@elf.ucw.cz> <4486FD2F.8040205@gentoo.org> <20060608070525.GE3688@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@suse.cz>, linville@tuxdriver.com,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:34713 "EHLO amd.ucw.cz")
	by vger.kernel.org with ESMTP id S932551AbWFHHNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 03:13:55 -0400
To: Daniel Drake <dsd@gentoo.org>
Content-Disposition: inline
In-Reply-To: <20060608070525.GE3688@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> > >Well, I'll try _enable() alone, but it seems to me that _enable()
> > >command is needed to initialize radio properly. I do not think we can
> > >get much further without firmware sources...
> > 
> > If you can formulate a proper and technical description of the issue 
> > (and exactly what is needed to workaround it), I can contact ZyDAS for 
> > you. They have been very helpful with ZD1211.
> 
> Okay, the issue is:
> 
> if you plug zd1201 into USB, it starts jamming radio,
> immediately. Enable/disable, or iwlist wlan0 scan, or basically any
> operation unjams the radio. This patch works it around:

Of course, the patch should have been:

 diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
 index 335eaf3..dcc7bc7 100644
 --- a/drivers/net/wireless/zd1201.c
 +++ b/drivers/net/wireless/zd1201.c
 @@ -1835,6 +1835,8 @@ static int zd1201_probe(struct usb_inter
  	    zd->dev->name);
  	
  	usb_set_intfdata(interface, zd);
 +	zd1201_enable(zd);	/* zd1201 likes to startup enabled, interfering */
 +	zd1201_disable(zd); 	/* with all the wifis in range */
  	return 0;
  
  err_net:
 
 
 ....question is "is that right solution, or is something different
 needed to solve that problem properly"?
 								Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
