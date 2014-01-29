From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: 3.14-mw regression: rtl8169 WARNING: DMA-API: exceeded 7
 overlapping mappings of pfn 55ebe
Date: Tue, 28 Jan 2014 19:06:24 -0800
Message-ID: <CAA9_cme2hgJ=jCDkPh5n5RP8fiJE-dVwbFr-apKv1=mNGPHYZg@mail.gmail.com>
References: <1859471893.20140126115521@eikelenboom.it>
	<20140127000305.GA14236@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Sander Eikelenboom <linux@eikelenboom.it>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140127000305.GA14236@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 26, 2014 at 4:03 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Sander Eikelenboom <linux@eikelenboom.it> :
> [...]
>> I have got a regression with a 3.14-mw kernel (last commit is 4ba9920e5e9c0e16b5ed24292d45322907bb9035):
>> It looks like it's related to the rtl8169 ...
>>
>> --
>> Sander
>>
>> Jan 26 11:36:26 serveerstertje kernel: [   89.105537] ------------[ cut here ]------------
>> Jan 26 11:36:26 serveerstertje kernel: [   89.116779] WARNING: CPU: 0 PID: 0 at lib/dma-debug.c:491 add_dma_entry+0x103/0x130()
>> Jan 26 11:36:26 serveerstertje kernel: [   89.128148] DMA-API: exceeded 7 overlapping mappings of pfn 55ebe
>> Jan 26 11:36:26 serveerstertje kernel: [   89.139397] Modules linked in:
>> Jan 26 11:36:26 serveerstertje kernel: [   89.150535] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.13.0-20140125-mw-pcireset+ #1
>> Jan 26 11:36:26 serveerstertje kernel: [   89.161784] Hardware name: MSI MS-7640/890FXA-GD70 (MS-7640)  , BIOS V1.8B1 09/13/2010
>> Jan 26 11:36:26 serveerstertje kernel: [   89.172965]  0000000000000009 ffff88005f603838 ffffffff81acbcfa ffffffff822134e0
>> Jan 26 11:36:26 serveerstertje kernel: [   89.184156]  ffff88005f603888 ffff88005f603878 ffffffff810bdf62 ffff880000000000
>> Jan 26 11:36:26 serveerstertje kernel: [   89.195186]  0000000000055ebe 00000000ffffffef 0000000000000200 ffff8800592ea098
>> Jan 26 11:36:26 serveerstertje kernel: [   89.206227] Call Trace:
>> Jan 26 11:36:26 serveerstertje kernel: [   89.217027]  <IRQ>  [<ffffffff81acbcfa>] dump_stack+0x46/0x58
>> Jan 26 11:36:26 serveerstertje kernel: [   89.227907]  [<ffffffff810bdf62>] warn_slowpath_common+0x82/0xb0
>> Jan 26 11:36:26 serveerstertje kernel: [   89.238678]  [<ffffffff810be031>] warn_slowpath_fmt+0x41/0x50
>> Jan 26 11:36:26 serveerstertje kernel: [   89.249336]  [<ffffffff81471c5a>] ? active_pfn_read_overlap+0x3a/0x70
>> Jan 26 11:36:26 serveerstertje kernel: [   89.259904]  [<ffffffff814729e3>] add_dma_entry+0x103/0x130
>> Jan 26 11:36:26 serveerstertje kernel: [   89.270416]  [<ffffffff81472de6>] debug_dma_map_page+0x126/0x150
>> Jan 26 11:36:26 serveerstertje kernel: [   89.280840]  [<ffffffff81714686>] rtl8169_start_xmit+0x216/0xa20
> [r8169 and xen stuff]
>
> Dan, I miss the part of the debug code that tells where the mappings were
> previously set.

In this case it was a facepalm mistake on my part.  The mappings were
not being properly accounted in the last revision of the patch I sent.
 I copied you on the fix [1].

--
Dan

[1]: http://marc.info/?l=linux-netdev&m=139096447627032&w=2
