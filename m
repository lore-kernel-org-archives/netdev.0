From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [RFC] vlan: add sysfs support
Date: Mon, 1 May 2006 23:31:35 +0200
Message-ID: <20060501213135.GB21191@mars.ravnborg.org>
References: <20060501140834.43a006fd@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	vlan@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtp.tele.dk ([193.162.159.95]:59657 "EHLO pasmtp.tele.dk")
	by vger.kernel.org with ESMTP id S932277AbWEAVbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 May 2006 17:31:49 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060501140834.43a006fd@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 01, 2006 at 02:08:34PM -0700, Stephen Hemminger wrote:
> Add basic sysfs support for vlan device. It creates an entry in the
> vlan pseudo-device to display tag.  
> 	/sys/class/net/eth0.5/vlan_id
> 
> It would be nice at some future to have something like:
> 	/sys/class/net/eth0/tags/5  -> ../../eth0.5
> as well.
> 
> There is a race with udev though. The sysfs entry can't be created
> until after the the class_device is registered but the registration
> doesn't happen until  rtnl_unlock after register_netdevice. The class_device
> registration causes the hotplug event, so the hotplug user program
> might get there before vlan_id is created.
> 
> 
> --- vlan.orig/net/8021q/Makefile	2006-05-01 12:50:58.000000000 -0700
> +++ vlan/net/8021q/Makefile	2006-05-01 14:04:56.000000000 -0700
> @@ -6,7 +6,5 @@
>  
>  8021q-objs := vlan.o vlan_dev.o
Please make this
>  8021q-y := vlan.o vlan_dev.o

To avoid confusion.


>  
> -ifeq ($(CONFIG_PROC_FS),y)
> -8021q-objs += vlanproc.o
> -endif
> -
> +8021q-$(CONFIG_PROC_FS) += vlanproc.o
> +8021q-$(CONFIG_SYSFS) += vlan_sysfs.o

	Sam
