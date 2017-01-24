From: "'Naveen N. Rao'" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] powerpc: bpf: implement in-register swap for 64-bit
 endian operations
Date: Tue, 24 Jan 2017 21:55:11 +0530
Message-ID: <20170124162511.GI3820@naverao1-tp.localdomain>
References: <e73efe6facf6c06932b4a87707e5978172ee773e.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
 <bb264395301754f43b77ddec68a16dd34220abb4.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DB02635FB@AcuExch.aculab.com>
 <20170113175201.GD3470@naverao1-tp.localdomain>
 <1484492458.11927.17.camel@au1.ibm.com>
 <20170123192227.GE3820@naverao1-tp.localdomain>
 <063D6719AE5E284EB5DD2968C1650D6DB026CE48@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Herrenschmidt <benh@au1.ibm.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "ast@fb.com" <ast@fb.com>,
        Madhavan Srinivasan <maddy@linux.vnet.ibm.com>,
        Michael Ellerman <mpe@ellerman.id.au>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:55683 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750707AbdAXQZZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 11:25:25 -0500
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0OGJtbo089728
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 11:25:25 -0500
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com [125.16.236.4])
        by mx0a-001b2d01.pphosted.com with ESMTP id 285jtvjwfa-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 11:25:24 -0500
Received: from localhost
        by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <naveen.n.rao@linux.vnet.ibm.com>;
        Tue, 24 Jan 2017 21:55:18 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
        by d28dlp03.in.ibm.com (Postfix) with ESMTP id 791CD125804F
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 21:56:55 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
        by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0OGPEYM37159058
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 21:55:14 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
        by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0OGPCCe026441
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 21:55:14 +0530
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB026CE48@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017/01/24 04:13PM, David Laight wrote:
> From: 'Naveen N. Rao'
> > Sent: 23 January 2017 19:22
> > On 2017/01/15 09:00AM, Benjamin Herrenschmidt wrote:
> > > On Fri, 2017-01-13 at 23:22 +0530, 'Naveen N. Rao' wrote:
> > > > > That rather depends on whether the processor has a store to load forwarder
> > > > > that will satisfy the read from the store buffer.
> > > > > I don't know about ppc, but at least some x86 will do that.
> > > >
> > > > Interesting - good to know that.
> > > >
> > > > However, I don't think powerpc does that and in-register swap is likely
> > > > faster regardless. Note also that gcc prefers this form at higher
> > > > optimization levels.
> > >
> > > Of course powerpc has a load-store forwarder these days, however, I
> > > wouldn't be surprised if the in-register form was still faster on some
> > > implementations, but this needs to be tested.
> > 
> > Thanks for clarifying! To test this, I wrote a simple (perhaps naive)
> > test that just issues a whole lot of endian swaps and in _that_ test, it
> > does look like the load-store forwarder is doing pretty well.
> ...
> > This is all in a POWER8 vm. On POWER7, the in-register variant is around
> > 4 times faster than the ldbrx variant.
> ...
> 
> I wonder which is faster on the little 1GHz embedded ppc we use here.

Worth a test, for sure.
FWIW, this patch won't matter since eBPF JIT is for ppc64.

Thanks,
Naveen
