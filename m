From: Michael Buesch <mb@bu3sch.de>
Subject: Re: bcm43xx driver unstable behaviour (and linux wireless is junk btw)
Date: Sun, 24 Sep 2006 18:38:35 +0200
Message-ID: <200609241838.35838.mb@bu3sch.de>
References: <1159065798.5924.8.camel@localhost.localdomain> <200609241043.49772.mb@bu3sch.de> <4516A578.2030105@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	netdev@vger.kernel.org, Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:21171
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750756AbWIXQiz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Sep 2006 12:38:55 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <4516A578.2030105@gentoo.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 24 September 2006 17:34, Daniel Drake wrote:
> Michael Buesch wrote:
> > Well. Works For Me (tm).
> > If there is some bug for you in current mainline, it needs to
> > be fixed. But I can't fix something I am not able to reproduce and
> > don't know what happens.
> 
> Take a look at the logs in Ben's original mail. I've seen this a lot 
> myself and am fairly sure that the problem is softmac's handling of a 
> SIWESSID *immediately* followed by a SIWAP call. This is what 
> wpa_supplicant does, and the timing screws us over.
> 
> You can see in the logs that the driver starts authenticating after the 
> first ioctl comes in, but then starts scanning (in preparation for 
> authentication, again) as soon as the 2nd call comes in immediately 
> after. As the device is busy scanning other channels it misses the 
> authentication response, and this goes round in circles.
> 
> Now, Jose recently bolted on a few more lock-like flags onto the whole 
> auth+assoc procedure, which has certainly helped, but the races do still 
> exist, and I don't think that approach is practical: there are simply 
> too many points in the sequence where softmac could be 'interrupted' by 
> another ESSID/AP call.
> 
> But, I'd be absolutely delighted if I'm missing something and you can 
> fix it :)

Ok, thanks for the explaination. I will look into the issue.
I remember seeing racing wext calls, too.

-- 
Greetings Michael.
