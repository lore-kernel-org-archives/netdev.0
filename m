From: Tobias Waldekranz <tobias@waldekranz.com>
Subject: Re: [PATCH 2/2] dsa: mv88e6131: support fixed PHYs
Date: Sat, 21 Feb 2015 11:30:05 +0100
Message-ID: <20150221103005.GA9212@gmail.com>
References: <20150212141317.GB12318@gmail.com>
 <CAGVrzcb5Vcx3fwFf3sVBGqw9QgZp9PD3TOZhO-CT5Eevzz5rzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:45627 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbbBUKaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 05:30:14 -0500
Received: by labge10 with SMTP id ge10so10513167lab.12
        for <netdev@vger.kernel.org>; Sat, 21 Feb 2015 02:30:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAGVrzcb5Vcx3fwFf3sVBGqw9QgZp9PD3TOZhO-CT5Eevzz5rzw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 12, 2015 at 08:13:28AM -0800, Florian Fainelli wrote:
> 2015-02-12 6:13 GMT-08:00 Tobias Waldekranz <tobias@waldekranz.com>:
> > Statically setup the PCS Control on the MAC to match the fixed PHY.
> 
> bcm_sf2 supports both fixed PHYs and regular PHYs, yet we do not need
> to get access to the fixed PHY status from the adjust_link callback
> because you could implement a separate fixed_link_update callback for
> that purpose.
> 
> Did not that work for you?
> 

That was my first approach and it worked fine. The only issue I saw
was that the callback was continously called at each poll cycle even
though the link state had not changed.

So then I implemented the same check for updates that was in the
regular adjust_link callback. But before I submitted that version of
the patch I looked att the sf2 code, and it seemed as though this code
uses the callback to update the phy status based on the chip state and
not the other way around. Did I misunderstand the code?

Not wanting to break your code, I went with this approach instead. But
if you're fine with it, I'm more than happy to go with that version.

-- 
Thanks
 - wkz
