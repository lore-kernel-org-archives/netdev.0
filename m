From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC 1/3] net: dsa: add basic support for VLAN ndo
Date: Sun, 31 May 2015 09:14:01 -0700
Message-ID: <CAE4R7bB6V4RkxuucGFxL=kQWfwjmjuN_yT+Vs8xXmGUrS7mcyA@mail.gmail.com>
References: <556723FF.7030606@roeck-us.net> <1432849035-8499-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1432849035-8499-2-git-send-email-vivien.didelot@savoirfairelinux.com>
 <CAJ3xEMjYn+eeGHi5dyAhjHivid4UKUyGAi8pwVD4PBhKn1HTKQ@mail.gmail.com>
 <2010513546.247697.1432913908579.JavaMail.zimbra@savoirfairelinux.com>
 <CAJ3xEMhAusqPj9m2a-wx7FDC2rE+WUk3UobE3+nS8qRV8bWTGg@mail.gmail.com>
 <5568E4FB.6060309@roeck-us.net> <332498294.570457.1432940265841.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Guenter Roeck <linux@roeck-us.net>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	=?UTF-8?Q?J=C3=A9rome_Oufella?=
	<jerome.oufella@savoirfairelinux.com>,
	Chris Healy <cphealy@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:35766 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758152AbbEaQOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 12:14:23 -0400
Received: by qgg60 with SMTP id 60so41584647qgg.2
        for <netdev@vger.kernel.org>; Sun, 31 May 2015 09:14:22 -0700 (PDT)
In-Reply-To: <332498294.570457.1432940265841.JavaMail.zimbra@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2015 at 3:57 PM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:

> Scott,
>
> Can I ask details about this NETIF_F_HW_SWITCH_OFFLOAD flag? Why is it
> unneeded?

Sorry, the commit message for that changes wasn't very good because it
didn't capture the email discussion leading up.

The issue I had with the flag was it could be set/cleared at any time
and it wasn't clear what the driver should do in response.

Let's say flag is on for swp1, on startup.  swp1 driver offloads L2/L3
to the device.  Next user clears flag with ethtool.  What does that
mean?  That existing offloads should be removed from device?  Or just
stop adding/removing offloads while flag is off?  Stopping offloads
can cause problems for L3 offload by breaking LPM rules.  (You could
end up with a shorter prefix route in HW and a longer prefix route in
SW, and the HW route will win, which would be bad).

So Roopa wants to revisit the flag.  I might be that tightening up
when the flag can be set/cleared will fix the sequencing issues.

-scott
