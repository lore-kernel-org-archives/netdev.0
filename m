From: "pradeep singh" <2500.pradeep@gmail.com>
Subject: Re: tg3 issues
Date: Thu, 19 Jul 2007 16:49:13 +0530
Message-ID: <366312910707190419se33ddd2o3870b5684e077276@mail.gmail.com>
References: <469E78A2.80904@imperialnet.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: patric <pakar@imperialnet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:25667 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758058AbXGSLTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 07:19:15 -0400
Received: by ug-out-1314.google.com with SMTP id j3so385090ugf
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 04:19:14 -0700 (PDT)
In-Reply-To: <469E78A2.80904@imperialnet.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CCing: netdev

On 7/19/07, patric <pakar@imperialnet.org> wrote:
> Hi,
>
>
> To start with, i'm not sure if this should go to the dev or user list,
> but i'll start here..
>
>
> I'm currently running a nfsroot via a Broadcom NetXtreme 1000-SX card
> (BCM5701) and i have a big problem with the tg3 drivers autonegotiation.
>
> The issue seems to be that when the kernel comes so far as it's trying
> to mount the boot the autonegotiation has not yet completed and then
> causes a panic since it cannot mount the nfsroot.
>
>
>  From some debugging i have done here the issues seems to be related to
> the flowcontrol configuration, and just to make it a bit more fun it
> does work some of the time.. (around once every 5-10 attempts.)
>
>
> On the console it looks something like this when failing. (written from
> memory since i don't have netconsole enabled)
>
> tg3: eth0: Link is up at 1000 Mbps, full duplex.
> tg3: eth0: Flow control is off for TX and off for RX.
> IP-Config: Complete:
>       device=eth0, addr=192.168.1.10, mask=255.255.255.0,
> gw=255.255.255.255,
>      host=amd, domain=, nis-domain=(none),
>      bootserver=255.255.255.255, rootserver=192.168.1.1, rootpath=
> Root-NFS: unknown option: nolocks
> Looking up port of RPC 100003/3 on 192.168.1.1
> rpcbind: server 192.168.1.1 not responding, timed out
>
> Root-NFS: Unable to get nfsd port number from server, using default
>
> Looking up port of RPC 100003/3 on 192.168.1.1
> rpcbind: server 192.168.1.1 not responding, timed out
>
> Root-NFS: Unable to get nfsd port number from server, using default
>
>
> and so on until it panics...
>
>
> And for a successful attempt:
>
> tg3: eth0: Link is up at 1000 Mbps, full duplex.
> tg3: eth0: Flow control is off for TX and off for RX.
> IP-Config: Complete:
>       device=eth0, addr=192.168.1.10, mask=255.255.255.0,
> gw=255.255.255.255,
>      host=amd, domain=, nis-domain=(none),
>      bootserver=255.255.255.255, rootserver=192.168.1.1, rootpath=
> Root-NFS: unknown option: nolocks
> Looking up port of RPC 100003/3 on 192.168.1.1
> tg3: eth0: Link is up at 1000 Mbps, full duplex.
> tg3: eth0: Flow control is on for TX and on for RX.
> rpcbind: server 192.168.1.1 not responding, timed out
> Root-NFS: Unable to get nfsd port number from server, using default
> Looking up port of RPC 100005/3 on 192.168.1.1
> VFS: Mounted root (nfs filesystem).
>
>
> Also, if  i get the "flowcontrol is on" before it tries to mount the
> root it does not report any issues. And this is also not unique to NFS
> booting, but anytime i bring the link up (when not using it for booting).
>
>
> Currently i'm running 2.6.22-git9 (for testing) and i experience the
> same issues in plain 2.6.22 and before.
>
>
> Regards,
>
> Patric
>
>
>
>
>
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
play the game
