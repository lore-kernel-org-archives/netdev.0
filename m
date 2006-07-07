From: Marcus Better <marcus@better.se>
Subject: Re: rtl8139: NETDEV WATCHDOG: eth0: transmit timed out
Date: Fri, 07 Jul 2006 18:32:59 +0200
Message-ID: <44AE8CBB.4070409@better.se>
References: <e82qhq$4v0$1@sea.gmane.org> <20060630211604.GA5302@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alan Hourihane <alanh@tungstengraphics.com>,
	dri-devel@lists.sourceforge.net, Dave Airlie <airlied@linux.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxfep01.bredband.com ([195.54.107.70]:37001 "EHLO
	mxfep01.bredband.com") by vger.kernel.org with ESMTP
	id S932205AbWGGQdL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 12:33:11 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060630211604.GA5302@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

(For those haven't followed, this is about
  http://permalink.gmane.org/gmane.linux.network/38493
)

Francois Romieu wrote:
> Marcus Better <marcus@better.se> :
>> I'm seeing this problem on my Acer Travelmate 223X laptop with built-in
>> Realtek 8139: The ethernet stops working, usually after at most a few
>> minutes operation.

> In a better world, you would narrow the suspect with a git bissect [1]
> between v2.6.15 and v2.6.16.

I did, and the winner after 13 reboots is...

commit de227f5f32775d86e5c780a7cffdd2e08574f7fb
Author: Dave Airlie <airlied@starflyer.(none)>
Date:   Wed Jan 25 15:31:43 2006 +1100

    drm: i915 patches from Tungsten Graphics

    Fix CMDBUFFER path, add heap destroy and flesh out sarea for rotation
    (Tungsten Graphics)

    From: Alan Hourihane <alanh@tungstengraphics.com>
    Signed-off-by: Dave Airlie <airlied@linux.ie>


I didn't believe it at first either, but blacklisting the i915 module
actually fixes the problem. Now that I know what to look for, I notice
that the network errors always started cropping up after X11 started.

Wonder what's going on here. Why is the graphics driver killing my network?

Marcus
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQFEroy7XjXn6TzcAQkRAp7bAJ9F7HgWg+VsvQ0fwkK3+b4Ne+tASwCg8+m3
8i5BoW+ujUjoX3DLW0QKAPQ=
=MDAc
-----END PGP SIGNATURE-----
