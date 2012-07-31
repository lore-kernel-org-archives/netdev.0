From: Bernard Pidoux <bernard.pidoux@free.fr>
Subject: Re: CPU: 0 Not tainted  (3.1.9+ #1) when ifconfig rose0 down
Date: Tue, 31 Jul 2012 17:27:39 +0200
Message-ID: <5017F96B.1060701@free.fr>
References: <5017E786.5000102@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-hams <linux-hams@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <5017E786.5000102@free.fr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is a complementary observation.
Trying to remove rose module with rmmod rose did not create any kernel 
panic.
However, there is an endless message from the kernel saying :

Message from syslogd@raspberrypi at Jul 31 17:22:40 ...
  kernel:[  831.579007] unregister_netdevice: waiting for rose0 to 
become free. Usage count = 23

Message from syslogd@raspberrypi at Jul 31 17:22:50 ...
  kernel:[  841.739390] unregister_netdevice: waiting for rose0 to 
become free. Usage count = 23

Message from syslogd@raspberrypi at Jul 31 17:23:00 ...
  kernel:[  851.899758] unregister_netdevice: waiting for rose0 to 
become free. Usage count = 23
.....

As observed at many occasions, count number seems to be random ! and
the same message keeps going without any change of count number.
At the same time, there is no possibility to recover the command line on 
any console.
However I could loggin via ssh and I noticed that rose0 device is 
actually no more in the ifconfig list.

If I try to remove rose with rmmod rose I get :

root@raspberrypi:/home/pi# rmmod rose
libkmod: ERROR ../libkmod/libkmod-module.c:753 
kmod_module_remove_module: could not remove 'rose': Device or resource busy
Error: could not remove module rose: Device or resource busy


Does this help ?


On 31/07/2012 16:11, Bernard Pidoux wrote:
> Hi,
>
> I observe systematically a kernel panic when I try to shutdown rose0
> device using ifconfig rose0 down
>
> This is happening on two very different ROSE implementation, one is on a
> machine with x86-64 kernel 4.6.3 on an Intel core 2 duo CPU
> the other is on a RaspBerry Pi with Raspbian and 3.1.9+ wheezy kernel
> recompiled with AX.25 modules (ax25, rose, netrom, 6pack, kiss) enabled.
>
> Here is an image of the screen dump :
>
> http://f6bvp.org/photos/rose_device_event.JPG
>
> It can be noticed that PC is at rose_device_event and
> LR is at sock_def_wakeup
>
> One thing to be noticed is that when I close before all ROSE and AX.25
> applications, there are still a few populated sockets, probably for one
> of the program did not close the sockets properly.
>
> I that case, does rose module should accept to shutdown rose0 device ?
> However, I guess that it should not create a kernel panic due to a
> kernel NULL pointer.
>
> I don't know what to do in order to debug that issue.
>
> Bernard
>

