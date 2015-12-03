From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Wed, 2 Dec 2015 18:08:44 -0800
Message-ID: <20151203020843.GA25113@ast-mbp.thefacebook.com>
References: <CAEh+42ivCoBE-vAwWpHHmHYqcXzKP+ceZSvg2rEPh7Db3M1k6Q@mail.gmail.com>
 <CALx6S35_rXPsYUGcc+yrQX8K1dOcL4aWnmQsa-6X6xULo9BBbg@mail.gmail.com>
 <CAEh+42gvn=cjZ4E3nACR7=-_a4iFS7OwEsSb+SQGme2k19kVAA@mail.gmail.com>
 <CALx6S37EoLM=bZ6sSAiiF81X=SvTvoNAmkbH5Dmn9zSvR2oiUA@mail.gmail.com>
 <20151201154445.GF29497@tuxdriver.com>
 <1448984968.3382143.454794705.68D88B7D@webmail.messagingengine.com>
 <CALx6S36i7Ee3Njs6OPVndyoGz1OpYss3YRPG8KO2ehxvAe50dA@mail.gmail.com>
 <1449074114.3806253.455834737.16948E5F@webmail.messagingengine.com>
 <CALx6S34Zqn1t4RPkAoa3QT-vWLvawnBN19qEZ12P-YiCEckxHw@mail.gmail.com>
 <565F8059.3010101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jesse Gross <jesse@kernel.org>,
	David Miller <davem@davemloft.net>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36019 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757719AbbLCCOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 21:14:34 -0500
Received: by pfdd184 with SMTP id d184so3438915pfd.3
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 18:14:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <565F8059.3010101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 02, 2015 at 03:35:53PM -0800, John Fastabend wrote:
> [...]
> > BPF. Implementing protocol generic offloads are not just a HW concern
> > either, adding kernel GRO code for every possible protocol that comes
> > along doesn't scale well. This becomes especially obvious when we
> > consider how to provide offloads for applications protocols. If the
> > kernel provides a programmable framework for the offloads then
> > application protocols, such as QUIC, could use use that without
> > needing to hack the kernel to support the specific protocol (which no
> > one wants!). Application protocol parsing in KCM and some other use
> > cases of BPF have already foreshadowed this, and we are working on a
> > prototype for a BPF programmable engine in the kernel. Presumably,
> > this same model could eventually be applied as the HW API to
> > programmable offload.
> 
> Just keying off the last statement there...
> 
> I think BPF programs are going to be hard to translate into hardware
> for most devices. The problem is the BPF programs in general lack
> structure. A parse graph would be much more friendly for hardware or
> at minimum the BPF program would need to be a some sort of
> well-structured program so a driver could turn that into a parse graph.

I'm looking at bpf as a way to describe the intent of what HW or SW has to do
and in case of SW it's easy to JIT and execute, but nic/switch doesn't
have to 'execute' bpf instructions. If it's fpga based it can compile
bpf program into parallel gates. Less flexible HW would not be able
to off-load all programs. That's fine. Long term flexible SW will
push HW to be flexible.
