From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Subject: Re: change kmalloc into vmalloc for large memory
	allocations
Date: Mon, 3 Mar 2014 09:55:15 +0800
Message-ID: <35FD53F367049845BC99AC72306C23D102844605F38E@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D102844605F38C@CNBJMBX05.corpusers.net>
 <s5hlhwvb9q8.wl%tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'alsa-devel@alsa-project.org'" <alsa-devel@alsa-project.org>,
 "'broonie@opensource.wolfsonmicro.com'"
 <broonie@opensource.wolfsonmicro.com>,
 "'fweisbec@gmail.com'" <fweisbec@gmail.com>,
 "'dmitry.torokhov@gmail.com'" <dmitry.torokhov@gmail.com>,
 "'coreteam@netfilter.org'" <coreteam@netfilter.org>,
 "'linux-input@vger.kernel.org'" <linux-input@vger.kernel.org>,
 "'rydberg@euromail.se'" <rydberg@euromail.se>, "'lrg@ti.com'" <lrg@ti.com>,
 "'pablo@netfilter.org'" <pablo@netfilter.org>,
 "'linux-arm-msm@vger.kernel.org'" <linux-arm-msm@vger.kernel.org>,
 "'rostedt@goodmis.org'" <rostedt@goodmis.org>,
 "'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>,
 "'mingo@redhat.com'" <mingo@redhat.com>,
 "'linux-arm-kernel@lists.infradead.org'"
 <linux-arm-kernel@lists.infradead.org>,
 "'gregkh@linuxfoundation.org'" <gregkh@linuxfoundation.org>,
 "'linux-usb@vger.kernel.org'" <linux-us
To: 'Takashi Iwai' <tiwai@suse.de>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <s5hlhwvb9q8.wl%tiwai@suse.de>
Content-Language: en-US
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

Hi  Takashi,

For this one:
https://git.kernel.org/cgit/linux/kernel/git/will/linux.git/tree/sound/soc/soc-core.c?h=master#n3772

in my kernel log,
the allocation size 62496,
about 62KB,
I think need to  change to vmalloc .
How do you think of it ?

Logs:
<4>[   11.469789] ------------[ cut here ]------------
<4>[   11.469803] WARNING: at /media/00DE7FE2DE7FCE82/jb-mr2-yukon/kernel/include/linux/slub_def.h:265 __kmalloc+0x38/0x29c()
<4>[   11.469811] size=62496 flags=80d0
<4>[   11.469815] Modules linked in:
<4>[   11.469835] [<c010c534>] (unwind_backtrace+0x0/0x11c) from [<c018ab04>] (warn_slowpath_common+0x4c/0x64)
<4>[   11.469850] [<c018ab04>] (warn_slowpath_common+0x4c/0x64) from [<c018ab9c>] (warn_slowpath_fmt+0x2c/0x3c)
<4>[   11.469864] [<c018ab9c>] (warn_slowpath_fmt+0x2c/0x3c) from [<c0249ab4>] (__kmalloc+0x38/0x29c)
<4>[   11.469879] [<c0249ab4>] (__kmalloc+0x38/0x29c) from [<c06a0124>] (snd_soc_register_card+0x184/0x104c)
<4>[   11.469896] [<c06a0124>] (snd_soc_register_card+0x184/0x104c) from [<c088183c>] (msm8226_asoc_machine_probe+0x298/0x7f0)
<4>[   11.469913] [<c088183c>] (msm8226_asoc_machine_probe+0x298/0x7f0) from [<c044b1fc>] (platform_drv_probe+0x14/0x18)
<4>[   11.469927] [<c044b1fc>] (platform_drv_probe+0x14/0x18) from [<c0449f2c>] (driver_probe_device+0x134/0x334)
<4>[   11.469940] [<c0449f2c>] (driver_probe_device+0x134/0x334) from [<c044a194>] (__driver_attach+0x68/0x8c)
<4>[   11.469953] [<c044a194>] (__driver_attach+0x68/0x8c) from [<c044849c>] (bus_for_each_dev+0x48/0x80)
<4>[   11.469965] [<c044849c>] (bus_for_each_dev+0x48/0x80) from [<c0449528>] (bus_add_driver+0x100/0x26c)
<4>[   11.469978] [<c0449528>] (bus_add_driver+0x100/0x26c) from [<c044a66c>] (driver_register+0x9c/0x120)
<4>[   11.469992] [<c044a66c>] (driver_register+0x9c/0x120) from [<c010052c>] (do_one_initcall+0x90/0x160)
<4>[   11.470007] [<c010052c>] (do_one_initcall+0x90/0x160) from [<c0d00b74>] (kernel_init+0xec/0x1a8)
<4>[   11.470022] [<c0d00b74>] (kernel_init+0xec/0x1a8) from [<c0106aec>] (kernel_thread_exit+0x0/0x8)
<4>[   11.470030] ---[ end trace 1b75b31a2719ed4d ]---

BRs/ Yalin
-----Original Message-----
From: Takashi Iwai [mailto:tiwai@suse.de] 
Sent: Friday, February 28, 2014 10:20 PM
To: Wang, Yalin
Cc: 'linux-kernel@vger.kernel.org'; 'linux-arm-msm@vger.kernel.org'; 'linux-arm-kernel@lists.infradead.org'; 'linux-input@vger.kernel.org'; 'balbi@ti.com'; 'gregkh@linuxfoundation.org'; 'lrg@ti.com'; 'broonie@opensource.wolfsonmicro.com'; 'perex@perex.cz'; 'pablo@netfilter.org'; 'kaber@trash.net'; 'davem@davemloft.net'; 'rostedt@goodmis.org'; 'fweisbec@gmail.com'; 'mingo@redhat.com'; 'dmitry.torokhov@gmail.com'; 'rydberg@euromail.se'; 'linux-usb@vger.kernel.org'; 'alsa-devel@alsa-project.org'; 'netfilter-devel@vger.kernel.org'; 'netfilter@vger.kernel.org'; 'coreteam@netfilter.org'; 'netdev@vger.kernel.org'
Subject: Re: change kmalloc into vmalloc for large memory allocations

At Fri, 28 Feb 2014 16:15:23 +0800,
Wang, Yalin wrote:
> 
> Hi
> 
> 
> I find there is some drivers use kmalloc to allocate large Memorys 
> during module_init,  some can be changed to use vmalloc To save some 
> low mem, I add log in kernel to track , And list them here:
> 
> https://git.kernel.org/cgit/linux/kernel/git/will/linux.git/tree/drive
> rs/usb/gadget/f_mass_storage.c?h=master#n2724
> 
> https://git.kernel.org/cgit/linux/kernel/git/will/linux.git/tree/sound
> /soc/soc-core.c?h=master#n3772

At least the ASoC runtime case doesn't use the allocated memory as buffer, and they are allocated only once per device, thus it shouldn't be the problem you stated.  If it really consumes so much memory, we need to rethink, instead of allocating an array but allocate each object, for example.


thanks,

Takashi


> https://git.kernel.org/cgit/linux/kernel/git/will/linux.git/tree/net/n
> etfilter/nf_conntrack_ftp.c?h=master#n603
> https://git.kernel.org/cgit/linux/kernel/git/will/linux.git/tree/net/n
> etfilter/nf_conntrack_h323_main.c?h=master#n1849
> https://git.kernel.org/cgit/linux/kernel/git/will/linux.git/tree/net/n
> etfilter/nf_conntrack_irc.c?h=master#n247
> https://git.kernel.org/cgit/linux/kernel/git/will/linux.git/tree/net/n
> etfilter/nf_conntrack_sane.c?h=master#n195
> 
> https://git.kernel.org/cgit/linux/kernel/git/will/linux.git/tree/drive
> rs/input/evdev.c?h=master#n403
> 
> 
> they allocate large memory from 10k~64K , this will use lots of low 
> mem, instead if we use vmalloc for these drivers , it will be good for 
> some devices like smart phone, we often encounter some errors like 
> kmalloc failed because there is not enough low mem , especially when 
> the device has physical memory less than 1GB .
> 
> 
> could this module change the memory allocation into vmalloc ?
> 
> I was thinking that if we can introduce a helper function in kmalloc.h like this :
> 
> Kmalloc(size, flags)
> {
> 	If (size > PAGE_SIZE && flags&CAN_USE_VMALLOC_FLAG)
> 		return vmalloc(size);
> 	Else
> 		return real_kmalloc(size);
> }
> 
> Kfree(ptr)
> {
> 	If (is_vmalloc_addr(ptr))
> 		Vfree(ptr);
> 	Else
> 		Kfree(ptr);
> }
> 
> 
> But we need add some flags to ensure always use kmalloc for Some 
> special use (dma etc..)
> 
> How do you think of it ?
> 
> Thanks
> 
> 
> 
