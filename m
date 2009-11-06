From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Using netconsole and getting double prints
Date: Thu, 5 Nov 2009 16:54:14 -0800
Message-ID: <43e72e890911051654i19c18bf3nd397662ed79712c4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756347AbZKFAyd@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm getting double prints when using netconsole. This used to happen
to me and then I just enable debugging log level manually (dmesg -n 8)
but now no matter what I try I always get double prints.

For example:

[   23.425448] console [netcon0] enabled
[   23.425567] netconsole: network logging started
[   23.425448] console [netcon0] enabled
[   23.425567] netconsole: network logging started
[   32.856073] eth0: no IPv6 routers present
[   32.856073] eth0: no IPv6 routers present
[   66.307342] kmemleak: 6 new suspected memory leaks (see
/sys/kernel/debug/kmemleak)
[   66.307342] kmemleak: 6 new suspected memory leaks (see
/sys/kernel/debug/kmemleak)

Instead of dmesg -8 I'm now using ignore_loglevel as a kernel
parameter but I still get double prints. This also happens if I use
"debug" as a kernel parameter instead.

The netconsole is set up on the dev box as follows through an /etc/rc.local

dhclient eth0
IP=192.168.2
# sudo dmesg -n 8
modprobe netconsole netconsole=@/eth0,6666@${IP}/
exit 0

I capture my data with netcat script (I call it netlog):

#!/bin/bash
echo "You should now run in another window: tail -f $HOME/log"
while true; do
	/bin/nc -u -l -p 6666 >> $HOME/log
done

This also just doesn't work if I run the nc manually without a redirect:

while true; do /bin/nc -u -l -p 6666; done

Any ideas?

  Luis
