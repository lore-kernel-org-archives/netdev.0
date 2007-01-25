From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Re: [RFC PATCH] bcm43xx: set channel when the interface is brought up
Date: Thu, 25 Jan 2007 12:47:08 +0100
Message-ID: <a32f33a40701250347q5c9aa5fby785181f77fc9bb4@mail.gmail.com>
References: <1169707854.10593.41.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
To: "Pavel Roskin" <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:28101 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbXAYLrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 06:47:11 -0500
Received: by nf-out-0910.google.com with SMTP id o25so826766nfa
        for <netdev@vger.kernel.org>; Thu, 25 Jan 2007 03:47:10 -0800 (PST)
In-Reply-To: <1169707854.10593.41.camel@dv>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> I have discovered that while I can indeed associate without
> wpa_supplicant using bcm43xx_d80211 driver, I have to set the channel
> every time the interface is brought down and up.
>
> It turns out d80211 uses the "config" method of the hardware drivers
> very sparingly.  It's only used for scanning and in ioctl commands.  It
> is not called after the interface has been brought up with the "open"
> method.

Correct, similar problems have been detected in rt2x00. The temporary
solution in there is to demand a scanning operation after the interface
has been brought up.

> I don't know whose responsibility it should be to apply the
> configuration when the interface is brought up.  I'm not familiar with
> d80211 design principles.

Well my personal preference would be if the dscape stack handles it,
unless the stack guarentees the conf structure has been initialized
and contains valid data when the interface is being brought up.

Ivo
