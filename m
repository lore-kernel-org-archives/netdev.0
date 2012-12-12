From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Tue, 11 Dec 2012 16:50:27 -0800
Message-ID: <CAOxq_8N_XtupUAr9fhU8zAi1fdkqMTqTA1bm_x93+eoAhxoZ1A@mail.gmail.com>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	<3246.1351717319@obiwan.sandelman.ca>
	<CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	<87mwyi9h1x.fsf@xmission.com>
	<alpine.OSX.2.00.1212111432430.78903@animac.local>
	<1355267060.27891.139.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Michael Richardson <mcr@sandelman.ca>, netdev@vger.kernel.org,
	tcpdump-workers@lists.tcpdump.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:34410 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788Ab2LLAu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 19:50:27 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so148695iay.19
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2012 16:50:27 -0800 (PST)
In-Reply-To: <1355267060.27891.139.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 11, 2012 at 3:04 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2012-12-11 at 14:36 -0800, Ani Sinha wrote:
>> >
>> > It is possible to test for the presence of support of the new vlan bpf

> If you want to test ANCILLARY possible values, its already too late, as
> old kernels wont use any patch anyway.
>

So basically this means that if we generate a filter with these
special negative offset values and expect that the kernel will
complain if it does not recognize the newer values then we would be
wrong. And you are right. Old kernels never knew about them and the
code wasn't written in a way to return EINVAL if it didn't recognize a
special negative anciliary offset value.
