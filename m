From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: tg3 issues
Date: Thu, 19 Jul 2007 07:37:55 -0400
Message-ID: <20070719113755.GA1934@hmsreliant.homelinux.net>
References: <469E78A2.80904@imperialnet.org> <366312910707190419se33ddd2o3870b5684e077276@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: patric <pakar@imperialnet.org>, linux-net@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: pradeep singh <2500.pradeep@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <366312910707190419se33ddd2o3870b5684e077276@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 19, 2007 at 04:49:13PM +0530, pradeep singh wrote:
> CCing: netdev
> 
> On 7/19/07, patric <pakar@imperialnet.org> wrote:
> >Hi,
> >
> >
> >To start with, i'm not sure if this should go to the dev or user list,
> >but i'll start here..
> >
> >
> >I'm currently running a nfsroot via a Broadcom NetXtreme 1000-SX card
> >(BCM5701) and i have a big problem with the tg3 drivers autonegotiation.
> >
> >The issue seems to be that when the kernel comes so far as it's trying
> >to mount the boot the autonegotiation has not yet completed and then
> >causes a panic since it cannot mount the nfsroot.
> >
> >
> > From some debugging i have done here the issues seems to be related to
> >the flowcontrol configuration, and just to make it a bit more fun it
> >does work some of the time.. (around once every 5-10 attempts.)
> >
> >
> >On the console it looks something like this when failing. (written from
> >memory since i don't have netconsole enabled)
> >
> >tg3: eth0: Link is up at 1000 Mbps, full duplex.
> >tg3: eth0: Flow control is off for TX and off for RX.
> >IP-Config: Complete:
> >      device=eth0, addr=192.168.1.10, mask=255.255.255.0,
> >gw=255.255.255.255,
> >     host=amd, domain=, nis-domain=(none),
> >     bootserver=255.255.255.255, rootserver=192.168.1.1, rootpath=
> >Root-NFS: unknown option: nolocks
> >Looking up port of RPC 100003/3 on 192.168.1.1
> >rpcbind: server 192.168.1.1 not responding, timed out
> >
> >Root-NFS: Unable to get nfsd port number from server, using default
> >
> >Looking up port of RPC 100003/3 on 192.168.1.1
> >rpcbind: server 192.168.1.1 not responding, timed out
> >
> >Root-NFS: Unable to get nfsd port number from server, using default
> >
> >
> >and so on until it panics...
> >

IIRC, there are two main problems in this typ of situation

1) Spanning tree convergence
2) Firmware initalization latency

If you are running spanning tree on your network, it can take up to 2 minutes
before your port will forward frames properly.  if you have the options
available, disable spanning tree on the switch port connected to your host
system, or at least enable portfast if it is an option.  That should fix any
spanning tree issues you have

If the tg3 card is just taking a long time to initalize, there is not too much
you can do about it.  If your goal is to use nfs root, I would, instead of
enabling nfs-root as a kernel config option, I would create an initramfs that:
A) Brings up your NIC
B) Mounts your nfs partition
C) executes a switch_root or pivot_root operation

That way you can calibrate a delay between steps (A) and (B) in your initramfs
init script

Regards
Neil

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@tuxdriver.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/
