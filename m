From: Steve Glendinning <steve@shawell.net>
Subject: Re: [PATCH][RFC] smsc95xx: enable dynamic autosuspend (RFC)
Date: Tue, 11 Dec 2012 13:12:21 +0000
Message-ID: <CAKh2mn7FTMLkkCDw14RVV4ExK4mfLq=zmpgtFbwLjV0P4w3TqA@mail.gmail.com>
References: <1353607526-19307-6-git-send-email-steve.glendinning@shawell.net>
	<CAKh2mn5LgZBJDJWNzN8A3NK72Vk_fiUjJfmdn5njSrm400q36w@mail.gmail.com>
	<CACVXFVOBgwoSyUDzxD+ghjkpFu5PL7MuaS5UJOZYvVnV0dwhGg@mail.gmail.com>
	<1881907.JmjSTg2PBW@linux-lqwf.site>
	<CACVXFVMNshNMJ+hYHTCfE2+UOuMgGLb0dKq8qEM-LfUseuy2qA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Oliver Neukum <oliver@neukum.org>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:57860 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753100Ab2LKNMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 08:12:22 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so1491427eaa.19
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2012 05:12:21 -0800 (PST)
In-Reply-To: <CACVXFVMNshNMJ+hYHTCfE2+UOuMgGLb0dKq8qEM-LfUseuy2qA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11 December 2012 12:53, Ming Lei <ming.lei@canonical.com> wrote:
> On Tue, Dec 11, 2012 at 6:27 PM, Oliver Neukum <oliver@neukum.org> wrote:
>> So they can autosuspend if the interface is up and no cable is plugged
>> in?
>
> From the open datasheet, that is the suspend 1 mode, which is supported
> by all LAN95xx devices. Steve, correct me if I am wrong.

All parts support SUSPEND1, but some parts can't 100% reliably wake on
ENERGYON - some link partners will wake them but others won't.  The
driver already detects parts that work reliably with all link partners
and sets the FEATURE_PHY_NLP_CROSSOVER feature flag.

I didn't block these devices from configuring WOL, because they do
work in *some* cases and the user is explicitly requesting to wake the
system so we try to do that (and sometimes succeed).

>>> I suggest to introduce link-off triggered runtime suspend for these
>>> usbnet devices(non-LAN9500A device, devices which don't support
>>> USB auto-suspend), and I have posted one patch set before[1].
>>> If no one objects that, I'd like to post them again with some fix and
>>> update for checking link after link_reset().
>>
>> If you can get rid of a periodic work this would be great.
>
> For the LAN95xx devices, the periodic work isn't needed because
> they may generate remote wakeup when link change is detected.

As above, some parts will do this but some will not.  I think we
should only consider sleeping the part if we're sure it'll wake up
when a cable is connected!

-- 
Steve Glendinning
