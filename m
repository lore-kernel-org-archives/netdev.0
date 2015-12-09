From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Tue, 8 Dec 2015 21:45:46 -0800
Message-ID: <20151209054543.GA7902@ast-mbp.thefacebook.com>
References: <1448984968.3382143.454794705.68D88B7D@webmail.messagingengine.com>
 <CALx6S36i7Ee3Njs6OPVndyoGz1OpYss3YRPG8KO2ehxvAe50dA@mail.gmail.com>
 <1449074114.3806253.455834737.16948E5F@webmail.messagingengine.com>
 <CALx6S34Zqn1t4RPkAoa3QT-vWLvawnBN19qEZ12P-YiCEckxHw@mail.gmail.com>
 <565F8059.3010101@gmail.com>
 <CALx6S35EwSXNvOxf_a+=5n2xBN6ZTq--cxdciNgCzPnqzxACJA@mail.gmail.com>
 <566687DC.7040805@gmail.com>
 <5666E7EB.40709@mojatatu.com>
 <5666F2DB.5000101@mojatatu.com>
 <20151209014038.GA19097@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jesse Gross <jesse@kernel.org>,
	David Miller <davem@davemloft.net>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33401 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531AbbLIFpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 00:45:53 -0500
Received: by pabur14 with SMTP id ur14so24182931pab.0
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 21:45:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20151209014038.GA19097@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 09, 2015 at 02:40:38AM +0100, Thomas Graf wrote:
> 
> I'm still having a difficulty trying to understand what exactly
> the intended proposal around this is. You may have just answered
> my question but just to make sure: When people refer to
> implementing or interpreting BPF in hardware, do they mean:
> 
>  1) A limited BPF instruction set used as descriptive language
>     to define match/action logic?
>  2) A specific (versioned) BPF instruction set which hardware
>     can support?
>  3) The full BPF instruction set of the current kernel + all
>     defined helper functions and tail call support?

definetely not 1, not 2 and hardly 3.
bpf verifier in 2k lines does full code analysis with all branches,
memory accesses and so on, so it's not hard to understand _intent_
of the program by any HW backend.
I agree with John that it's not trivial to convert bpf program into
parse graph that intel asic understands, but it's not hard either.
fpga based nic/switch can convert a program into parallel gates.
netronom nic can JIT it into their instruction set.
Programmable switch asics can equally understand intent of the
program and convert it into their firmware.
The easiest would be arm-based nics.
In all cases HW will not be able to convert all possible programs,
but it's not a limitation of instruction set. That's why 1 and 2
above doesn't really apply.
Different explanation of the above:
think of bpf as intermediate representation. When C or some other
language is used to describe what dataplane suppose to do
the compiler generates bpf==IR which is later compiled by hw specific
backend into target. That target can be fpga, asic, npu, etc.
Some backends will be simple and small enough to stay completely
within kernel. Some backends (like fpga) would need to
call_usermodehelper() or similar, since netlist compilation is
tedious and slow process.
