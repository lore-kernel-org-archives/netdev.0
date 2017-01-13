From: "'Naveen N. Rao'" <naveen.n.rao@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] powerpc: bpf: implement in-register swap for 64-bit
 endian operations
Date: Fri, 13 Jan 2017 23:22:01 +0530
Message-ID: <20170113175201.GD3470@naverao1-tp.localdomain>
References: <e73efe6facf6c06932b4a87707e5978172ee773e.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
 <bb264395301754f43b77ddec68a16dd34220abb4.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DB02635FB@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "mpe@ellerman.id.au" <mpe@ellerman.id.au>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "ast@fb.com" <ast@fb.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:47176 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750992AbdAMRwM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 12:52:12 -0500
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0DHpoV0044378
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 12:52:12 -0500
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
        by mx0a-001b2d01.pphosted.com with ESMTP id 27y00ahxqs-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 12:52:11 -0500
Received: from localhost
        by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <naveen.n.rao@linux.vnet.ibm.com>;
        Sat, 14 Jan 2017 03:52:09 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
        by d23dlp02.au.ibm.com (Postfix) with ESMTP id 0C9482BB0045
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2017 04:52:07 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
        by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0DHq6p530277782
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2017 04:52:06 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
        by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0DHq507001948
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2017 04:52:06 +1100
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB02635FB@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017/01/13 05:17PM, David Laight wrote:
> From: Naveen N. Rao
> > Sent: 13 January 2017 17:10
> > Generate instructions to perform the endian conversion using registers,
> > rather than generating two memory accesses.
> > 
> > The "way easier and faster" comment was obviously for the author, not
> > the processor.
> 
> That rather depends on whether the processor has a store to load forwarder
> that will satisfy the read from the store buffer.
> I don't know about ppc, but at least some x86 will do that.

Interesting - good to know that.

However, I don't think powerpc does that and in-register swap is likely 
faster regardless. Note also that gcc prefers this form at higher 
optimization levels.

Thanks,
Naveen
