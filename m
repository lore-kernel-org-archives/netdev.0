From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: change kmalloc into vmalloc for large memory
	allocations
Date: Fri, 28 Feb 2014 09:11:38 -0500
Message-ID: <20140228091138.39b90f52@gandalf.local.home>
References: <35FD53F367049845BC99AC72306C23D102844605F38C@CNBJMBX05.corpusers.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'alsa-devel@alsa-project.org'" <alsa-devel@alsa-project.org>,
 "'linux-usb@vger.kernel.org'" <linux-usb@vger.kernel.org>,
 "'tiwai@suse.de'" <tiwai@suse.de>, "'fweisbec@gmail.com'" <fweisbec@gmail.com>,
 "'dmitry.torokhov@gmail.com'" <dmitry.torokhov@gmail.com>,
 "'mingo@redhat.com'" <mingo@redhat.com>,
 "'linux-input@vger.kernel.org'" <linux-input@vger.kernel.org>,
 "'rydberg@euromail.se'" <rydberg@euromail.se>, "'lrg@ti.com'" <lrg@ti.com>,
 "'pablo@netfilter.org'" <pablo@netfilter.org>,
 "'coreteam@netfilter.org'" <coreteam@netfilter.org>,
 "'linux-arm-msm@vger.kernel.org'" <linux-arm-msm@vger.kernel.org>,
 "'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>,
 "'linux-arm-kernel@lists.infradead.org'"
 <linux-arm-kernel@lists.infradead.org>,
 "'gregkh@linuxfoundation.org'" <gregkh@linuxfoundation.org>,
 "'broonie@opensource.wolfsonmicro.com'" <broonie@opensource.wolfsonmicro.
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <35FD53F367049845BC99AC72306C23D102844605F38C@CNBJMBX05.corpusers.net>
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

On Fri, 28 Feb 2014 16:15:23 +0800
"Wang, Yalin" <Yalin.Wang@sonymobile.com> wrote:

> Kfree(ptr)
> {
> 	If (is_vmalloc_addr(ptr))
> 		Vfree(ptr);
> 	Else
> 		Kfree(ptr);
> }
> 
> 
> But we need add some flags to ensure always use kmalloc for
> Some special use (dma etc..)
> 
> How do you think of it ?

But vmalloc also takes up tlb entries. The more vmalloc space you have,
the more tlb entries that will need to be used, which will have a
performance affect on the entire system.

I would be against making kmalloc() secretly doing a vmalloc. If it is
better for a driver to use a vmalloc on large items, than change the
driver. Don't change a core function.

-- Steve
