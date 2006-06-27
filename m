From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 27 Jun 2006 22:23:19 +0200
Message-ID: <200606272223.19928.mb@bu3sch.de>
References: <20060626212547.GE30706@tuxdriver.com> <200606272147.04477.mb@bu3sch.de> <44A18FE3.1080403@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:61159
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1030341AbWF0UXx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 16:23:53 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44A18FE3.1080403@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 27 June 2006 22:06, Larry Finger wrote:
> John,
> 
> I would like to find a diplomatic solution to this impasse between Michael and Jeff, which is why 
> I'm writing to you privately. Michael is correct in that the loop in question will not usually delay 

private?

> long; however, on some hardware it takes longer than on his. On mine, I have seen delays as long as 
> 550 usec.

What's the chip?

> In any case, I think that the following code fragment would work and pass Jeff's criticism: 
> 
> for (i=5000; i; i--) {
> 	..........
> 	usleep(1);

usleep? Can't find that in my kernel tree.
In fact, I think the lowest possible sleep time
depends on HZ and is 1msec on 1000HZ.

Additionally, we are holding a spinlock at this time, so it is
not as easy as simply replacing udelay() by some sleeping function.

> This would make the worst-case delay be 5 msec, but would provide a cushion of 10X the longest I 
> have seen and should be safe.
> 
> Do you have any suggestions on what should be done next?

Leave it as is and find out why it takes so long for your strange card. ;)

-- 
Greetings Michael.
