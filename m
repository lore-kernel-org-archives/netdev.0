From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Subject: RE: change kmalloc into vmalloc for large memory allocations
Date: Mon, 3 Mar 2014 10:51:23 +0800
Message-ID: <35FD53F367049845BC99AC72306C23D102844605F38F@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D102844605F38C@CNBJMBX05.corpusers.net>
 <53104ECA.4010702@freescale.com>
 <35FD53F367049845BC99AC72306C23D102844605F38D@CNBJMBX05.corpusers.net>
 <20140228163304.GA15614@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: "'alsa-devel@alsa-project.org'" <alsa-devel@alsa-project.org>,
 "'broonie@opensource.wolfsonmicro.com'"
 <broonie@opensource.wolfsonmicro.com>, "'tiwai@suse.de'" <tiwai@suse.de>,
 "'fweisbec@gmail.com'" <fweisbec@gmail.com>,
 "'perex@perex.cz'" <perex@perex.cz>, "'mingo@redhat.com'" <mingo@redhat.com>,
 "'linux-input@vger.kernel.org'" <linux-input@vger.kernel.org>,
 "'rydberg@euromail.se'" <rydberg@euromail.se>, "'lrg@ti.com'" <lrg@ti.com>,
 "'pablo@netfilter.org'" <pablo@netfilter.org>,
 "'coreteam@netfilter.org'" <coreteam@netfilter.org>,
 "'linux-arm-msm@vger.kernel.org'" <linux-arm-msm@vger.kernel.org>,
 "'rostedt@goodmis.org'" <rostedt@goodmis.org>,
 "'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>,
 "'linux-arm-kernel@lists.infradead.org'"
 <linux-arm-kernel@lists.infradead.org>,
 "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
 "'dmitry.torokhov@gmail.com'" <dmit
To: "'gregkh@linuxfoundation.org'" <gregkh@linuxfoundation.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20140228163304.GA15614@kroah.com>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi  greg,

I am sorry,
I make a mistake ,
You are right ,
https://git.kernel.org/cgit/linux/kernel/git/will/linux.git/tree/drivers/usb/gadget/f_mass_storage.c?h=master#n2724

this one should not changed to use vmalloc,
the buffer will be used by DMA，

others should be safe to change:

https://git.kernel.org/cgit/linux/kernel/git/will/linux.git/tree/sound/soc/soc-core.c?h=master#n3772

https://git.kernel.org/cgit/linux/kernel/git/will/linux.git/tree/net/netfilter/nf_conntrack_ftp.c?h=master#n603
https://git.kernel.org/cgit/linux/kernel/git/will/linux.git/tree/net/netfilter/nf_conntrack_h323_main.c?h=master#n1849
https://git.kernel.org/cgit/linux/kernel/git/will/linux.git/tree/net/netfilter/nf_conntrack_irc.c?h=master#n247
https://git.kernel.org/cgit/linux/kernel/git/will/linux.git/tree/net/netfilter/nf_conntrack_sane.c?h=master#n195

https://git.kernel.org/cgit/linux/kernel/git/will/linux.git/tree/drivers/input/evdev.c?h=master#n403


Thanks 
-----Original Message-----
From: 'gregkh@linuxfoundation.org' [mailto:gregkh@linuxfoundation.org] 
Sent: Saturday, March 01, 2014 12:33 AM
To: Wang, Yalin
Cc: 'Huang Shijie'; 'linux-kernel@vger.kernel.org'; 'linux-arm-msm@vger.kernel.org'; 'linux-arm-kernel@lists.infradead.org'; 'linux-input@vger.kernel.org'; 'balbi@ti.com'; 'lrg@ti.com'; 'broonie@opensource.wolfsonmicro.com'; 'perex@perex.cz'; 'tiwai@suse.de'; 'pablo@netfilter.org'; 'kaber@trash.net'; 'davem@davemloft.net'; 'rostedt@goodmis.org'; 'fweisbec@gmail.com'; 'mingo@redhat.com'; 'dmitry.torokhov@gmail.com'; 'rydberg@euromail.se'; 'linux-usb@vger.kernel.org'; 'alsa-devel@alsa-project.org'; 'netfilter-devel@vger.kernel.org'; 'netfilter@vger.kernel.org'; 'coreteam@netfilter.org'; 'netdev@vger.kernel.org'
Subject: Re: change kmalloc into vmalloc for large memory allocations

On Fri, Feb 28, 2014 at 05:20:08PM +0800, Wang, Yalin wrote:
> Hi
> 
> 
> Yeah,
> Dma buffer must be allocated by kmalloc,
> 
> But the modules I list should can all be changed to use vmalloc, 
> because the buffer is only used by software, Not by any hardware .

Are you sure about that?  The USB gadget driver needs DMA memory from what I can tell, have you tried your change out on a system that does not allow the USB controller to access non-DMA memory?

And I agree with Steve, just fix the individual drivers, don't do a "hidden" change of where the memory is allocated from, that's not a good idea and will cause problems later.

greg k-h
