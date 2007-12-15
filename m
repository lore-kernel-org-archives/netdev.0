From: "Holger Hoffstaette" <holger@wizards.de>
Subject: Re: Reproducible data corruption with sendfile+vsftp - splice regression?
Date: Sat, 15 Dec 2007 14:43:18 +0100
Message-ID: <pan.2007.12.15.13.43.18.232625@wizards.de>
References: <pan.2007.11.29.23.42.52.661624@wizards.de> <474FC4D9.3020506@cosmosbay.com> <pan.2007.11.30.09.20.24.737500@wizards.de> <475055EE.9060105@hp.com> <pan.2007.12.02.16.00.03.568000@wizards.de> <pan.2007.12.02.20.49.42.675000@wizards.de> <20071205225429.GA10186@electric-eye.fr.zoreil.com> <pan.2007.12.06.09.28.08.913625@wizards.de> <20071206184426.GA32599@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1765139AbXLONoU@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 06 Dec 2007 19:44:26 +0100, Francois Romieu wrote:

> Holger Hoffstaette <holger@wizards.de> : [...]
>> Maybe turning off sendfile or NAPI just lead to random success - so far
>> it really looks like tso on the r8169 is the common cause.
> 
> TSO on the r8169 is the magic switch but the regression makes imvho more
> sense from a VM pov:
> 
> - the corrupted file has the same size as the expected file
> - the corrupted file exhibits holes which come as a multiple of 4096 bytes
>   (8*4k, 2 places, there may be more)
> - the r8169 driver does not know what a page is
> - the 8169 hardware has a small 8192 bytes Tx buffer
> 
> It would be nice if someone could do a sendfile + vsftp test with TSO on a
> different hardware. While I could not reproduce the corruption when simply
> downloading a file that I had copied on the server with scp, it triggered
> almost immediately after I copied it locally and tried to download the
> copy.

I tested 2.6.24-rc5 on my T60 (Intel e1000 built with NAPI) and installed
vsftp/apache with sendfile and enabled all offload options incl. TSO.
Repeated downloads of >500 MB with ftp or wget over the NIC onto ram- or
physical disk gives no corruption whatsoever. Speed of download to ramdisk
is a nice continuous 125 MB/sec.
Looks like the r8169 or the driver after all..

thanks
Holger


