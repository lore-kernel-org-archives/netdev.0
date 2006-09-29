From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: Network problem with 2.6.18-mm1 ?
Date: Fri, 29 Sep 2006 11:08:10 -0700
Message-ID: <4807377b0609291108x84f39c6ic4c669fd91f8fcd4@mail.gmail.com>
References: <20060928013724.GA22898@us.ibm.com> <451B2D29.9040306@intel.com>
	 <20060928185222.GB3352@us.ibm.com>
	 <4807377b0609281410p28d445c8mc32e7d2cb71221ab@mail.gmail.com>
	 <20060929005205.GA3876@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Auke Kok" <auke-jan.h.kok@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Andrew Morton" <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:57763 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1751252AbWI2SIM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 14:08:12 -0400
Received: by ug-out-1314.google.com with SMTP id o38so301301ugd
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2006 11:08:11 -0700 (PDT)
To: "Sukadev Bhattiprolu" <sukadev@us.ibm.com>
In-Reply-To: <20060929005205.GA3876@us.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/28/06, Sukadev Bhattiprolu <sukadev@us.ibm.com> wrote:
> $ cat /proc/interrupts
>
>            CPU0       CPU1
>  28:          0          0   IO-APIC-fasteoi  eth0
> NMI:         96         35
> LOC:      18251      18524
> ERR:          0

you should be getting an interrupt every two seconds from the eth0
(e1000) driver.  You are having interrupt delivery problems probably
due to something screwing up interrupt routing in the kernel.
Normally these issues are associated with MSI interrupts but your
adapter doesn't support those and is using generic IRQ

I'm guessing that if you somehow enable interrupts on your vga card on
the same bus as e1000 (bus 3) it will have interrupt delivery problems
as well.  Maybe try xorg?

Jesse
