From: Richard Genoud <richard.genoud@gmail.com>
Subject: Re: hv_netvsc: WARNING in softirq.c
Date: Fri, 5 Apr 2013 12:59:52 +0200
Message-ID: <CACQ1gAgh7QX=cDYsrw9J5qYNKYpgQ841QijA145TDO_Ae5EsQQ@mail.gmail.com>
References: <20130228083437.GA28143@lnx-rg> <78fd1c1df13b449887de6e0b3505a988@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <CACQ1gAgyYp+Dxmk-0C3zfKK+CkEwQX51NvWjzkV7=8GC3CD=Qg@mail.gmail.com>
 <4147bb5a7cf547c19c6a5a6b459a957d@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <CACQ1gAi1NNwJ_QDp7ipjwdYCskENGN=N-j+TFD5aHX8DHnoBQA@mail.gmail.com> <CACQ1gAiadLrJQkDFe7_TEM_1OVSjECyewmxHyXvOcYCc7GLn_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: KY Srinivasan <kys@microsoft.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACQ1gAiadLrJQkDFe7_TEM_1OVSjECyewmxHyXvOcYCc7GLn_Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/3/19 Richard Genoud <richard.genoud@gmail.com>:
> 2013/3/7 Richard Genoud <richard.genoud@gmail.com>:
>> 2013/3/6 Haiyang Zhang <haiyangz@microsoft.com>:
>>> I have found a simple way to reproduce this kind of warning:
>>> 1) reboot the VM (because this warning can be displayed only once.)
>>> 2) login to the host and open the VM [Settings]
>>> 3) Temporarily change the Network adapter's option [Virtual Switch] to "Not connected".
>>> 4) run dmesg, you should see the warning.
>>>
>>> The reason for the warning is -- netif_tx_disable() is called when the NIC
>>> is disconnected. And it's called within irq context. netif_tx_disable()
>>> calls local_bh_enable() which displays warning if in irq.
>>>
>>> The fix is to remove the unnecessary netif_tx_disable() in the netvsc_linkstatus_callback().
>>> I attached a patch. Would you like to test it on your side as well?
>
> I installed the patched kernel today.
> here are the stats of the warings until today :
> kern.log.1:Mar 12 22:32:10 devlabo kernel: [30114.506299]
> ------------[ cut here ]------------
> kern.log.2:Mar  5 22:30:48 devlabo kernel: [10455.098586]
> ------------[ cut here ]------------
> kern.log.2:Mar  6 22:31:25 devlabo kernel: [85552.645480]
> ------------[ cut here ]------------
> kern.log.3:Feb 26 22:35:14 devlabo kernel: [37398.788119]
> ------------[ cut here ]------------
> kern.log.3:Feb 27 22:34:37 devlabo kernel: [10688.187196]
> ------------[ cut here ]------------
> kern.log.4:Feb 22 22:32:22 devlabo kernel: [40399.795364]
> ------------[ cut here ]------------
>
> So, I'll wait for one or two weeks before sending some feedback.
>
Ok, it has been a little bit more than 2 weeks now, and I did not see
this warning any more, just the
"hv_vmbus: child device vmbus_0_8 unregistered" sometimes.

so it seems to be fixed !

Thanks !


Reported-by: Richard Genoud <richard.genoud@gmail.com>
Tested-by: Richard Genoud <richard.genoud@gmail.com>


Regards,
Richard
