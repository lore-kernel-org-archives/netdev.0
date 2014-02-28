From: "'gregkh@linuxfoundation.org'" <gregkh@linuxfoundation.org>
Subject: Re: change kmalloc into vmalloc for large memory
	allocations
Date: Fri, 28 Feb 2014 08:33:04 -0800
Message-ID: <20140228163304.GA15614@kroah.com>
References: <35FD53F367049845BC99AC72306C23D102844605F38C@CNBJMBX05.corpusers.net>
 <53104ECA.4010702@freescale.com>
 <35FD53F367049845BC99AC72306C23D102844605F38D@CNBJMBX05.corpusers.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'alsa-devel@alsa-project.org'" <alsa-devel@alsa-project.org>,
 "'broonie@opensource.wolfsonmicro.com'"
 <broonie@opensource.wolfsonmicro.com>, "'tiwai@suse.de'" <tiwai@suse.de>,
 "'fweisbec@gmail.com'" <fweisbec@gmail.com>,
 "'mingo@redhat.com'" <mingo@redhat.com>,
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
 "'dmitry.torokhov@gmail.com'" <dmitry.torokhov@gmail.com>,
 "'linux-kern
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Return-path: <alsa-devel-bounces@alsa-project.org>
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D102844605F38D@CNBJMBX05.corpusers.net>
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

On Fri, Feb 28, 2014 at 05:20:08PM +0800, Wang, Yalin wrote:
> Hi  
> 
> 
> Yeah,  
> Dma buffer must be allocated by kmalloc,
> 
> But the modules I list should can all be changed to use
> vmalloc, because the buffer is only used by software,
> Not by any hardware .

Are you sure about that?  The USB gadget driver needs DMA memory from
what I can tell, have you tried your change out on a system that does
not allow the USB controller to access non-DMA memory?

And I agree with Steve, just fix the individual drivers, don't do a
"hidden" change of where the memory is allocated from, that's not a good
idea and will cause problems later.

greg k-h
