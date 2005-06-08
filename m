From: James Ketrenos <jketreno@linux.intel.com>
Subject: Re: ipw2100: firmware problem
Date: Wed, 08 Jun 2005 11:58:59 -0500
Message-ID: <42A723D3.3060001@linux.intel.com>
References: <20050608142310.GA2339@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Netdev list <netdev@oss.sgi.com>,
	kernel list <linux-kernel@vger.kernel.org>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261344AbVFHQ75@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>
In-Reply-To: <20050608142310.GA2339@elf.ucw.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Machek wrote:

>Hi!
>
>I'm fighting with firmware problem: if ipw2100 is compiled into
>kernel, it is loaded while kernel boots and firmware loader is not yet
>available. That leads to uninitialized (=> useless) adapter.
>  
>
We've been looking into whether the initrd can have the firmware affixed
to the end w/ some magic bytes to identify it.  If it works, enhancing
the request_firmware to support both hotplug and an initrd approach may
be reasonable.

>What's the prefered way to solve this one? Only load firmware when
>user does ifconfig eth1 up? [It is wifi, it looks like it would be
>better to start firmware sooner so that it can associate to the
>AP...].
>  
>
The debate goes back and forth on whether devices should come up only
after they are told, or initialize and start looking for a network as
soon as the module is loaded.

I lean more toward having the driver just do what it is told, defaulting
to trying to scan and associate so link is ready as soon as possible. 
We've added module parameters to change that behavior (disable and
associate for the ipw2100).

James
