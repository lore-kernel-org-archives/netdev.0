From: Lu Baolu <baolu.lu@linux.intel.com>
Subject: Re: (4.3.0) r8152: deadlock related to runtime suspend?
Date: Mon, 7 Dec 2015 17:11:50 +0800
Message-ID: <56654D56.3080402@linux.intel.com>
References: <20151205105912.GA1766@al>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Peter Wu <peter@lekensteyn.nl>, linux-usb@vger.kernel.org,
	hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151205105912.GA1766@al>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Peter,

Have you ever tried disabling auto-pm? Did things go smoothly if auto-pm is disabled?

I always disable usb auto-pm in below way.

# echo on | tee /sys/bus/usb/devices/*/power/control
# echo on > /sys/bus/pci/devices/<bus_name>/power/control

Thanks,
Baolu

On 12/05/2015 06:59 PM, Peter Wu wrote:
> Hi,
>
> I rarely use a Realtek USB 3.0 Gigabit Ethernet adapter (vid/pid
> 0bda:8153), but when I did last night, it resulted in a lockup of
> processes doing networking ("ip link", "ping", "ethtool", ...).
>
> A (few) minute(s) before that event, I noticed that there was no network
> connectivity (ping hung) which was somehow solved by invoking "ethtool
> eth1" (triggering runtime pm wakeup?). This same trick did not work at
> the next event. Invoking "ethtool eth1", "ip link", etc. hung completely
> and interrupt (^C) did not work at all.
>
> Since that did not work, I pulled the USB adapter and re-inserted it,
> hoping it would reset things. That did not work at all, there was a
> "usb disconnect" message, but no further driver messages.
>
> Fast forward an hour, and it has become a disaster. I have terminated
> and killed many programs via SysRq but am still unable to get a stable
> system that does not hang on network I/O. Even the suspend process
> fails so in the end I attempted to shutdown the system. After half an
> hour after getting the poweroff message, I issued SysRq + B to reboot
> (since SysRq + O did not shut down either).
>
> Attached are logs with various various backtraces from SysRq and failed
> suspend. Let me know if you need more information!
>
> By the way, often I have to rmmod xhci and re-insert it, otherwise
> plugging it in does not result in a detection. A USB 2.0 port does not
> have this problem (runtime PM is enabled for all devices). This is the
> USB 3.0 port:
>
>     02:00.0 USB controller [0c03]: NEC Corporation uPD720200 USB 3.0
>     Host Controller [1033:0194] (rev 03)
