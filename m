From: Philippe De Muyter <phdm@macqel.be>
Subject: Re: [m68k, powerpc, dma, ethernet,
	freescale RFA] Coldfire m54xx FEC	ethernet driver
Date: Tue, 16 Oct 2012 10:03:49 +0200
Message-ID: <20121016080349.GA8427@frolo.macqel>
References: <1348473919-30257-1-git-send-email-phdm@macqel.be>
 <1348473919-30257-4-git-send-email-phdm@macqel.be>
 <506D3323.4000205@snapgear.com> <20121004073448.GA4339@frolo.macqel>
 <506D902C.30902@snapgear.com> <20121004145601.GA15358@frolo.macqel>
 <20121004150329.GB15358@frolo.macqel> <5073C05C.2080809@snapgear.com>
 <20121009090758.GA14142@frolo.macqel> <507D0109.1010103@snapgear.com>
Reply-To: uClinux development list <uclinux-dev@uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: uClinux development list <uclinux-dev@uclinux.org>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org,
 stany.marcel@novasys-ingenierie.com, linuxppc-dev@lists.ozlabs.org
To: Greg Ungerer <gerg@snapgear.com>
Return-path: <uclinux-dev-bounces@uclinux.org>
Content-Disposition: inline
In-Reply-To: <507D0109.1010103@snapgear.com>
List-Unsubscribe: <http://mailman.uclinux.org/mailman/options/uclinux-dev>,
 <mailto:uclinux-dev-request@uclinux.org?subject=unsubscribe>
List-Archive: <http://mailman.uclinux.org/pipermail/uclinux-dev>
List-Post: <mailto:uclinux-dev@uclinux.org>
List-Help: <mailto:uclinux-dev-request@uclinux.org?subject=help>
List-Subscribe: <http://mailman.uclinux.org/mailman/listinfo/uclinux-dev>,
 <mailto:uclinux-dev-request@uclinux.org?subject=subscribe>
Errors-To: uclinux-dev-bounces@uclinux.org
Sender: uclinux-dev-bounces@uclinux.org
List-Id: netdev.vger.kernel.org

Hi Greg,

On Tue, Oct 16, 2012 at 04:39:05PM +1000, Greg Ungerer wrote:
> Hi Philippe,
>
> On 09/10/12 19:07, Philippe De Muyter wrote:
>> [CCing lkml, linux-ppc, netdev, linux-m68k]
>>
>> Hello kernel sources architects
>>
>> I have a working driver for the m54xx FEC ethernet driver that I
>> would like to integrate in the kernel tree.  Problems are that
>> - this driver needs an associated DMA driver (provided by FreeScale)
>> wich is not dma-engine enabled
>> - they're are already many fec drivers in the kernel tree, and
>> at least one, fec_mpc52xx.c, seems to be very similar (information
>> below), to the one for the mcf54xx, except it uses a differently
>> named associated DMA driver (BestComm/SmartDma/SDMA) which is also
>> not dma-engine enabled, and even kept hidden in /arch/powerpc where
>> it is inaccessible when compiling for m68k.  The underlying DMA part
>> from Freescale however seems similar to the one used in the
>> m54xx. (again, see information below)
>>
>> So, now I am lost, what should I do ?
>>
>> The current state of my patches
>> [http://mailman.uclinux.org/pipermail/uclinux-dev/2012-September/052147.html]
>> is pushing the freescale provided MCD_DMA dma driver to /drivers/dma,
>> without adding the dma-engine compatibility layer, and adding the specific
>> fec_m54xx ethernet driver to /drivers/net/ethernet/freescale
>
> Do you get any responses?
> I didn't see any...

No, and none also about my simpler patch moving arch/powerpc/sysdev/bestcomm
to drivers/dma/bestcomm (except a private and useful one telling me how to
set '-M' option as default for 'git format-patch'), but at least this simpler
patch seems to be in a wait bucket at
http://patchwork.ozlabs.org/project/linuxppc-dev/list/.

Regards

Philippe

PS: -M as default for 'git format-patch':

put
	[diff]
		renames = true
in .git/config

>
> Regards
> Greg
>
>
>
>> On Tue, Oct 09, 2012 at 04:12:44PM +1000, Greg Ungerer wrote:
>>> Hi Philippe,
>>>
>>> On 05/10/12 01:03, Philippe De Muyter wrote:
>>>> On Thu, Oct 04, 2012 at 04:56:01PM +0200, Philippe De Muyter wrote:
>>>>> On Thu, Oct 04, 2012 at 11:33:32PM +1000, Greg Ungerer wrote:
>>>>>>
>>>>>> My biggest concern is the amount of MCD/DMA support code. And it is
>>>>>> all done quite differently to everything else in the kernel. We may
>>>>>> get a bit of push back from kernel folk who look after DMA.
>>>>>
>>>>> Actually, there is already a similar code in 
>>>>> arch/powerpc/sysdev/bestcomm
>>>>> (also from freescale, maybe an identical part, but I did not find any
>>>>> usable doc), but the powerpc folks kept that hidden in the arch/powerpc
>>>>> tree, instead of installing it in drivers/dma.
>>>>
>>>> The MCD DMA or DMA FEC code from freescale has a comment implying that
>>>> this
>>>> was first used in the MPC8220 part.  And Montavista has a MPC8220 port,
>>>> but
>>>> I did not find it, so I do not know where they installed the MCD DMA
>>>> driver.
>>>
>>> Ok, looks like there is a bit a variance in all this.
>>
>> I also began to read the mpc5200 user's guide parts about the fec and
>> BestComm/SmartDma/SDMA (not sure which one is the official FreeScale name)
>> and they look very similar, but not identical, to their m54xx 
>> counterparts.
>>
>> It seems possible to make the fec_mpc52xx.c driver work for the m54xx
>> but that needs at least:
>> - moving some files or part of them from /arch/powerpc/sysdev and
>>    /arch/powerpc/include/asm to /drivers/dma and /include/linux,
>> - renaming the fec_mpc52xx files to a more sensible name,
>> - providing out_be32 and in_be32 in /arch/m68k/include/asm/io.h,
>> - and then unifying the interface to BestComm/SmartDma/SDMA and MCD_DMA
>>    in mcf_52xx.c.
>>
>> An additional problem is that the freescale docs for powerpcs and for
>> coldfires do not use the same mnemonics for the same registers.
>>
>> e.g. FEC registers
>> 	offset	MPC5200		MCF5484
>> 	======	=======		=======
>> 	000	FEC_ID		n/a
>> 	004	IEVENT		EIR
>> 	008	IMASK		EIMR
>> 	010	R_DES_ACTIVE	n/a
>> 	014	X_DES_ACTIVE	n/a
>> 	024	ECNTRL		ECR
>> 	040	MII_DATA	MDATA
>> 	044	MII_SPEED	MSCR
>> 	064	MIB_CONTROL	MIBC
>> 	084	R_CNTRL		RCR
>> 	088	R_HASH		RHR
>> 	0C4	X_CNTRL		TCR
>> 	0E4	PADDR1		PALR
>> 	0E8	PADDR2		PAHR
>> 	0EC	OP_PAUSE	OPD
>> 	118	IADDR1		IAUR
>> 	11C	IADDR1		IALR
>> 	120	GADDR1		GAUR
>> 	124	GADDR2		GALR
>> 	144	X_WMRK		FECTFWR
>> 	184	RFIFO_DATA	FECRFDR
>> 	188	RFIFO_STATUS	FECRFSR
>> 	18C	RFIFO_CONTROL	FECRFCR
>> 	190	RFIFO_LRF_PTR	FECRLRFP
>> 	194	RFIFO_LWF_PTR	FECRLWFP
>> 	198	RFIFO_ALARM	FECRFAR
>> 	19C	RFIFO_RDPTR	FECRFRP
>> 	1A0	RFIFO_WRPTR	FECRFWP
>> 	1A4	TFIFO_DATA	FECTFDR
>> 	1A8	TFIFO_STATUS	FECTFSR
>> 	1AC	TFIFO_CONTROL	FECTFCR
>> 	1B0	TFIFO_LRF_PTR	FECTLRFP
>> 	1B4	TFIFO_LWF_PTR	FECTLWFP
>> 	1B8	TFIFO_ALARM	FECTFAR
>> 	1BC	TFIFO_RDPTR	FECTFRP
>> 	1C0	TFIFO_WRPTR	FECTFWP
>> 	1C4	RESET_CNTRL	FECFRST
>> 	1C8	XMIT_FSM	FECCTCWR
>>
>>> Probably the best thing to do is post the patches on the linux kernel
>>> mailing list then, asking for direction on a dma driver.
>>>
>>> I have no problem with it going into the arch/m68k area. So that is
>>> always an option.
>>
>> For the dma engines, the similarity is also obvious.  For example, find
>> below side by side mpc52xx and m54xx definitions for the
>> main DMA registers :
>>
>> from mpc52xx.h				from MCD_dma.h
>> /* SDMA */				/* MCD_DMA */
>> struct mpc52xx_sdma {			struct dmaRegs {
>>   u32 taskBar; /* 0x00 */		        u32 taskbar;
>>   u32 currentPointer; /* 0x04 */		        u32 currPtr;
>>   u32 endPointer; /* 0x08 */		        u32 endPtr;
>>   u32 variablePointer; /* 0x0c */	        u32 varTablePtr;
>>
>>   u8 IntVect1; /* 0x10 */		        u16 dma_rsvd0;
>>   u8 IntVect2; /* 0x11 */
>>   u16 PtdCntrl; /* 0x12 */		        u16 ptdControl;
>>
>>   u32 IntPend; /* 0x14 */		        u32 intPending;
>>   u32 IntMask; /* 0x18 */		        u32 intMask;
>>
>>   u16 tcr[16]; /* 0x1c .. 0x3a */	        u16 taskControl[16];
>>
>>   u8 ipr[32]; /* 0x3c .. 0x5b */		        u8  priority[32];
>>
>>   u32 cReqSelect; /* 0x5c */		        u32 initiatorMux;
>>   u32 task_size0; /* 0x60 */		        u32 taskSize0;
>>   u32 task_size1; /* 0x64 */		        u32 taskSize1;
>>   u32 MDEDebug; /* 0x68 */		        u32 dma_rsvd1;
>>   u32 ADSDebug; /* 0x6c */		        u32 dma_rsvd2;
>>   u32 Value1; /* 0x70 */			        u32 debugComp1;
>>   u32 Value2; /* 0x74 */			        u32 debugComp2;
>>   u32 Control; /* 0x78 */		        u32 debugControl;
>>   u32 Status; /* 0x7c */			        u32 debugStatus;
>>   u32 PTDDebug; /* 0x80 */		        u32 ptdDebug;
>> };					};

_______________________________________________
uClinux-dev mailing list
uClinux-dev@uclinux.org
http://mailman.uclinux.org/mailman/listinfo/uclinux-dev
This message was resent by uclinux-dev@uclinux.org
To unsubscribe see:
http://mailman.uclinux.org/mailman/options/uclinux-dev
