From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: Let's do P4
Date: Sat, 29 Oct 2016 15:54:21 +0100
Message-ID: <20161029155421.02d81125@jkicinski-Precision-T1700>
References: <20161029075328.GB1692@nanopsycho.orion>
        <20161029093905.GA1810@pox.localdomain>
        <20161029101003.GC1692@nanopsycho.orion>
        <20161029111548.GB1810@pox.localdomain>
        <20161029112834.GF1692@nanopsycho.orion>
        <20161029120932.GD1810@pox.localdomain>
        <20161029135855.GH1692@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
        davem@davemloft.net, jhs@mojatatu.com, roopa@cumulusnetworks.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        ast@kernel.org, daniel@iogearbox.net, prem@barefootnetworks.com,
        hannes@stressinduktion.org, jbenc@redhat.com, tom@herbertland.com,
        mattyk@mellanox.com, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, ivecera@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:25639 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751075AbcJ2Oy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Oct 2016 10:54:28 -0400
In-Reply-To: <20161029135855.GH1692@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 Oct 2016 15:58:55 +0200, Jiri Pirko wrote:
> Sat, Oct 29, 2016 at 02:09:32PM CEST, tgraf@suug.ch wrote:
> >On 10/29/16 at 01:28pm, Jiri Pirko wrote:  
> >> Sat, Oct 29, 2016 at 01:15:48PM CEST, tgraf@suug.ch wrote:  
> >> >So given the SKIP_SW flag, the in-kernel compiler is optional anyway.
> >> >Why even risk including a possibly incomplete compiler? Older kernels
> >> >must be capable of running along newer hardware as long as eBPF can
> >> >represent the software path. Having to upgrade to latest and greatest
> >> >kernels is not an option for most people so they would simply have to
> >> >fall back to SKIP_SW and do it in user space anyway.  
> >> 
> >> The thing is, if we needo to offload something, it needs to be
> >> implemented in kernel first. Also, I believe that it is good to have
> >> in-kernel p4 engine for testing and development purposes.  
> >
> >You lost me now :-) In an earlier email you said:
> >  
> >> It can be the other way around. The p4>ebpf compiler won't be complete
> >> at the beginning so it is possible that HW could provide more features.
> >> I don't think it is a problem. With SKIP_SW and SKIP_HW flags in TC,
> >> the user can set different program to each. I think in real life, that
> >> would be the most common case anyway.  
> >
> >If you allow to SKIP_SW and set different programs each to address
> >this, then how is this any different.
> >
> >I completely agree that kernel must be able to provide the same
> >functionality as HW with optional additional capabilities on top so
> >the HW can always bail out and punt to SW.
> >
> >[...]
> >  
> >> >I'm not seeing how either of them is more or less variable. The main
> >> >difference is whether to require configuring a single cls with both
> >> >p4ast + bpf or two separate cls, one for each. I'd prefer the single
> >> >cls approach simply because it is cleaner wither regard to offload
> >> >directly off bpf vs off p4ast.  
> >> 
> >> That's the bundle that you asked me to forget earlier in this email? :)  
> >
> >I thought you referred to the "store in same object file" as bundle.
> >I don't really care about that. What I care about is a single way to
> >configure this that works for both ASIC and non-ASIC hardware.
> >  
> >> >My main point is to not include a IR to eBPF compiler in the kernel
> >> >and let user space handle this instead.  
> >> 
> >> It we do it as you describe, we would be using 2 different APIs for
> >> offloaded and non-offloaded path. I don't believe it is acceptable as
> >> the offloaded features has to have kernel implementation. Therefore, I
> >> believe that p4ast as a kernel API is the only possible option.  
> >
> >Yes, the kernel has the SW implementation in eBPF. I thought that is
> >what you propose as well. The only difference is whether to generate
> >that eBPF in kernel or user space.
> >
> >Not sure I understand the multiple APIs point for offload vs
> >non-offload. There is a single API: tc. Both models require the user
> >to provide additional metadata to allow programming ASIC HW: p4ast
> >IR or whatever we agree on.  
> 
> If you do p4>ebpf in userspace, you have 2 apis:
> 1) to setup sw (in-kernel) p4 datapath, you push bpf.o to kernel
> 2) to setup hw p4 datapath, you push program.p4ast to kernel
> 
> Those are 2 apis. Both wrapped up by TC, but still 2 apis.
> 
> What I believe is correct is to have one api:
> 1) to setup sw (in-kernel) p4 datapath, you push program.p4ast to kernel
> 2) to setup hw p4 datapath, you push program.p4ast to kernel
> 
> In case of 1), the program.p4ast will be either interpreted by new p4
> interpreter, of translated to bpf and interpreted by that. But this
> translation code is part of kernel.

Option 3) use a well structured subset of eBPF as user space ABI ;)

In all seriousness, user space already has to have some knowledge about
the underlaying hardware today with different vendors picking different
TC classifiers for offload.  So I humbly agree that 2 APIs may be
acceptable here.
