From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Re: d80211: The struct ieee80211_hw_modes array is a pain
Date: Wed, 13 Dec 2006 12:23:00 +0100
Message-ID: <a32f33a40612130323o188e4319p816dd93a9fde4d14@mail.gmail.com>
References: <200612131142.20556.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jiri Benc" <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:11726 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964865AbWLMLXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 06:23:02 -0500
Received: by ug-out-1314.google.com with SMTP id 44so141271uga
        for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 03:23:00 -0800 (PST)
To: "Michael Buesch" <mb@bu3sch.de>
In-Reply-To: <200612131142.20556.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> I am currently porting the bcm43xx driver to my new Sonics
> Silicon Backplane busdriver.
> I am having a major pain implementing the hw->modes field
> for this. In particular, the problem is allocation.
> I always felt sick about hw->modes, but with my new code it's
> damn complicated to get allocation of the stuff right.
> The problem is, that I do not know in advance which PHYMODEs
> my device supports (in fact, we never knew that, but we worked
> around it (in a broken way)).
> We have the following scenario: The PHYs are probed one after
> each other. We have one data structure per PHY. This bites
> the static hw->modes array in its ass. I would either have to
> allocate it "big enough" at the first time (wasting lots of memory)
> or I'd have to re-allocate it every time a new PHY is probed.
> Another (much harder to fix) problem is the opposite of the probing:
> Removing the PHYs.
>
> So, what I'd like to have is:
>
> One struct ieee802111_hw_mode which I can embed into the PHY
> data structure. This struct is now dynamically registered to the
> ieee80211 subsystem (instead of doing a static array pain).
>
> Registering and unregistering would be done with simple linked lists,
> perhaps, in d80211.

Sounds good to me. This would also solve the issue where the dscape stack
would always select the first mode in the array as the default mode.
Which means that the array should always be allocated in a specific
order since if B is first followed by G, then B would always be used
(even if G is supported by the AP).

Ivo
