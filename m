From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: soft lockup detected with 2.6.16 kernel + e1000 driver under load
Date: Tue, 20 Jun 2006 14:17:39 -0700
Message-ID: <4807377b0606201417p57425900r22728e2af31cb2de@mail.gmail.com>
References: <d166fa5e0606061200x690a064fv4988dedaf0204c0e@mail.gmail.com>
	 <d166fa5e0606201411h22247490g6074b56fd8b0f9d8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.196]:21403 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1751101AbWFTVRk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 17:17:40 -0400
Received: by nz-out-0102.google.com with SMTP id o37so7257nzf
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2006 14:17:39 -0700 (PDT)
To: "Massimiliano Poletto" <max.poletto+usenet@gmail.com>
In-Reply-To: <d166fa5e0606201411h22247490g6074b56fd8b0f9d8@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/20/06, Massimiliano Poletto <max.poletto+usenet@gmail.com> wrote:
> Shaw Vrana asked me to resend the message below (originally posted to
> lkml) to this list.
>
> Note that I managed to make the problem go away by adding the boot
> options "pci=usepirqmask acpi=noirq".  I got the hint by reading dmesg
> output and Documentation/kernel-parameters.txt.  Still, maybe the
> information below and my apparent solution will be of use to someone
> more knowledgeable in this matter than I am.

thats odd that changing the kernel interrupt setup would make a difference.

How about compiling the e1000 driver with NAPI support?  I think your
problem will go away.  You don't have any choice but to run NAPI with
tg3, so please at least compare apples to apples by enabling NAPI and
re-running your test.

<snip>

> BUG: soft lockup detected on CPU#0!
>
> Pid: 0, comm:              swapper
> EIP: 0060:[<c035b3f6>] CPU: 0
> EIP is at netif_rx+0x131/0x18b
>  EFLAGS: 00000282    Not tainted  (2.6.16.19 #1)
> EAX: 00000000 EBX: f2781a80 ECX: c0514680 EDX: c3fa4560
> ESI: c3fa45e0 EDI: c051a000 EBP: 00000282 DS: 007b ES: 007b
> CR0: 8005003b CR2: 081ed000 CR3: 04356da0 CR4: 000006f0
>  [<f88bd9ea>] e1000_clean_rx_irq+0x214/0x63b [e1000]
>  [<f88c116c>] e1000_intr+0x13f/0x47d [e1000]

spinning here would pretty much be expected and is exactly what NAPI
is designed to fix.

Jesse
