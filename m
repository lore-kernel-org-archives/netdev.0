From: =?ISO-8859-1?Q?Thomas_Hellstr=F6m?= <thomas@tungstengraphics.com>
Subject: Re: rtl8139: NETDEV WATCHDOG: eth0: transmit timed out
Date: Sat, 08 Jul 2006 18:15:55 +0200
Message-ID: <44AFDA3B.6020904@tungstengraphics.com>
References: <e82qhq$4v0$1@sea.gmane.org>	<20060630211604.GA5302@electric-eye.fr.zoreil.com> <44AE8CBB.4070409@better.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Dave Airlie <airlied@linux.ie>, netdev@vger.kernel.org,
	dri-devel@lists.sourceforge.net,
	Alan Hourihane <alanh@tungstengraphics.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-8-31a.gmt.gbg.bostream.se ([82.182.75.118]:48362 "EHLO
	lin5.shipmail.org") by vger.kernel.org with ESMTP id S964886AbWGHQP6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 12:15:58 -0400
To: Marcus Better <marcus@better.se>
In-Reply-To: <44AE8CBB.4070409@better.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi!

Marcus Better wrote:

>-----BEGIN PGP SIGNED MESSAGE-----
>Hash: SHA1
>
>(For those haven't followed, this is about
>  http://permalink.gmane.org/gmane.linux.network/38493
>)
>
>Francois Romieu wrote:
>  
>
>>Marcus Better <marcus@better.se> :
>>    
>>
>>>I'm seeing this problem on my Acer Travelmate 223X laptop with built-in
>>>Realtek 8139: The ethernet stops working, usually after at most a few
>>>minutes operation.
>>>      
>>>
>
>  
>
>>In a better world, you would narrow the suspect with a git bissect [1]
>>between v2.6.15 and v2.6.16.
>>    
>>
>
>I did, and the winner after 13 reboots is...
>
>commit de227f5f32775d86e5c780a7cffdd2e08574f7fb
>Author: Dave Airlie <airlied@starflyer.(none)>
>Date:   Wed Jan 25 15:31:43 2006 +1100
>
>    drm: i915 patches from Tungsten Graphics
>
>    Fix CMDBUFFER path, add heap destroy and flesh out sarea for rotation
>    (Tungsten Graphics)
>
>    From: Alan Hourihane <alanh@tungstengraphics.com>
>    Signed-off-by: Dave Airlie <airlied@linux.ie>
>
>
>I didn't believe it at first either, but blacklisting the i915 module
>actually fixes the problem. Now that I know what to look for, I notice
>that the network errors always started cropping up after X11 started.
>
>Wonder what's going on here. Why is the graphics driver killing my network?
>  
>
I guess you got the wrong commit, and the correct one should be the one 
where Dave adds vblank interrupts. It should be close to the one you listed.

Some i915 chips have buggy interrupts. What happens is that the display 
interrupts are duplicated on the sound interrupt channel. Usually 
there's no interrupt handler there that recognizes them, and after a 
while, the kernel detects too many spurious interrupts and disables the 
sound IRQ line. If the network sits on the same IRQ line, it will be 
disabled as well. If you check your kernel logs, you will probably have 
messages about disabled IRQs.

A workaround is to add the "noirqdebug" (I hope I remember the spelling 
correctly) kernel option at boot time.

/Thomas




>Marcus
>-----BEGIN PGP SIGNATURE-----
>Version: GnuPG v1.4.3 (GNU/Linux)
>
>iD8DBQFEroy7XjXn6TzcAQkRAp7bAJ9F7HgWg+VsvQ0fwkK3+b4Ne+tASwCg8+m3
>8i5BoW+ujUjoX3DLW0QKAPQ=
>=MDAc
>-----END PGP SIGNATURE-----
>
>Using Tomcat but need to do more? Need to support web services, security?
>Get stuff done quickly with pre-integrated technology to make your job easier
>Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
>http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
>--
>_______________________________________________
>Dri-devel mailing list
>Dri-devel@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/dri-devel
>  
>

