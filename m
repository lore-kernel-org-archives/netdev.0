From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Wed, 16 Apr 2008 16:11:57 +0300
Message-ID: <4805FB1D.4070304@teltonika.lt>
References: <20080414213238.GB28833@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080414213238.GB28833-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

With the latest patch I always get BUG when closing my serial terminal
application. I have two different modems (GTM378 and GTM380) plugged at 
USB hub. Here is the dump:

BUG: sleeping function called from invalid context at 
drivers/usb/core/urb.c:542
in_atomic():1, irqs_disabled():0
Pid: 30031, comm: gtkterm Not tainted 2.6.24.4-64.fc8 #1

Call Trace:
  [<ffffffff811b5e40>] usb_kill_urb+0x1a/0xf1
  [<ffffffff81268512>] mutex_lock+0x1e/0x2f
  [<ffffffff810ab2a2>] fasync_helper+0x4a/0xcd
  [<ffffffff88308f57>] :hso:hso_stop_serial_device+0x85/0x99
  [<ffffffff8830971f>] :hso:hso_serial_close+0xea/0x110
  [<ffffffff8117bf26>] release_dev+0x212/0x618
  [<ffffffff8108ec31>] free_pages_and_swap_cache+0x73/0x8f
  [<ffffffff8117c33d>] tty_release+0x11/0x1a
  [<ffffffff810a152c>] __fput+0xc2/0x18f
  [<ffffffff8109ed3f>] filp_close+0x5d/0x65
  [<ffffffff8109ff0f>] sys_close+0x8d/0xca
  [<ffffffff8100c005>] tracesys+0xd5/0xda

BUG: scheduling while atomic: gtkterm/30031/0x10000100
Pid: 30031, comm: gtkterm Not tainted 2.6.24.4-64.fc8 #1

Call Trace:
  [<ffffffff812677a2>] schedule+0x91/0x706
  [<ffffffff81032f45>] __cond_resched+0x2d/0x55
  [<ffffffff81267f0f>] cond_resched+0x2e/0x39
  [<ffffffff811b5e45>] usb_kill_urb+0x1f/0xf1
  [<ffffffff81268512>] mutex_lock+0x1e/0x2f
  [<ffffffff810ab2a2>] fasync_helper+0x4a/0xcd
  [<ffffffff88308f57>] :hso:hso_stop_serial_device+0x85/0x99
  [<ffffffff8830971f>] :hso:hso_serial_close+0xea/0x110
  [<ffffffff8117bf26>] release_dev+0x212/0x618
  [<ffffffff8108ec31>] free_pages_and_swap_cache+0x73/0x8f
  [<ffffffff8117c33d>] tty_release+0x11/0x1a
  [<ffffffff810a152c>] __fput+0xc2/0x18f
  [<ffffffff8109ed3f>] filp_close+0x5d/0x65
  [<ffffffff8109ff0f>] sys_close+0x8d/0xca
  [<ffffffff8100c005>] tracesys+0xd5/0xda

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
