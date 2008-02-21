From: "Magnus Damm" <magnus.damm@gmail.com>
Subject: Re: [PATCH 02/04] smc91x: introduce platform data flags
Date: Thu, 21 Feb 2008 11:34:20 +0900
Message-ID: <aec7e5c30802201834h7eae8892n7b9434168944eace@mail.gmail.com>
References: <20080220095740.22645.36783.sendpatchset@clockwork.opensource.se>
	 <20080220095802.22645.44691.sendpatchset@clockwork.opensource.se>
	 <alpine.LFD.1.00.0802201044270.2732@xanadu.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lethal@linux-sh.org,
	akpm@linux-foundation.org
To: "Nicolas Pitre" <nico@cam.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.248]:51589 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbYBUCeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 21:34:23 -0500
Received: by ag-out-0708.google.com with SMTP id 33so4918030agc.1
        for <netdev@vger.kernel.org>; Wed, 20 Feb 2008 18:34:21 -0800 (PST)
In-Reply-To: <alpine.LFD.1.00.0802201044270.2732@xanadu.home>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 21, 2008 at 12:58 AM, Nicolas Pitre <nico@cam.org> wrote:
> On Wed, 20 Feb 2008, Magnus Damm wrote:
>
>  > This patch introduces struct smc91x_platdata and modifies the driver so
>  > bus width is checked during run time using SMC_nBIT() instead of
>  > SMC_CAN_USE_nBIT.
>  >
>  > Signed-off-by: Magnus Damm <damm@igel.co.jp>
>  > ---
>
>  NAK.
>
>  The SMC91C111 (for example) is often used on devices which have a CPU
>  clock barely higher than the network throughput, hence it is crutial for
>  those devices to have the most efficient access possible to the chip or
>  performance will suffer.  This is the main reason behind the heavily
>  macroized register access so things are always optimized for the data
>  bus capabilities at compile time.

I understand that you want to keep the code as fast as possible. So do
I. But I want to remove the need to modify smc91x.h for each board I
want to support. It is much better in my opinion to have a wide range
of boards supported but a little bit lower throughput compared to only
a few boards supported and excellent performance... People can always
modify the header file by themselves if they want to squeeze out that
extra percent of performance. But maybe that's just me wanting to
support more boards than I have time for. =)

>  This patch introduces a runtimes test on lp->cfg.flags for every
>  register access even on those platforms not using the platform data
>  based bus configuration at all.

Right. It's kind of hard to avoid the check if you want to select the
bus width using platform data though... =) I understand you want to
keep the compile time optimization working well, and this patch is not
so good in that regard.

>  I think you should add a SMC_DYNAMIC_BUS_CONFIG and redefine SMC_nBITS()
>  so they dereference cfg.flags only when it is defined.

Sure, good idea. I'll fix that. Do you mind if I make that the default
behavior? So boards that doesn't have any hard coded configuration in
smc91x.h can use the platform data flags method for configuration
instead.

Thanks for your feedback!

/ magnus
