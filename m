From: Benjamin Herrenschmidt <benh@au1.ibm.com>
Subject: Re: [PATCH 3/3] powerpc: bpf: implement in-register swap for 64-bit
 endian operations
Date: Sun, 15 Jan 2017 09:00:58 -0600
Message-ID: <1484492458.11927.17.camel@au1.ibm.com>
References: <e73efe6facf6c06932b4a87707e5978172ee773e.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
         <bb264395301754f43b77ddec68a16dd34220abb4.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
         <063D6719AE5E284EB5DD2968C1650D6DB02635FB@AcuExch.aculab.com>
         <20170113175201.GD3470@naverao1-tp.localdomain>
Reply-To: benh@au1.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "ast@fb.com" <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "davem@davemloft.net" <davem@davemloft.net>
To: "'Naveen N. Rao'" <naveen.n.rao@linux.vnet.ibm.com>,
        David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:50202 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751099AbdAOPBF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 10:01:05 -0500
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0FErvv1143133
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 10:01:05 -0500
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
        by mx0a-001b2d01.pphosted.com with ESMTP id 27ynrdgk1b-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 10:01:04 -0500
Received: from localhost
        by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <benh@au1.ibm.com>;
        Mon, 16 Jan 2017 01:01:01 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
        by d23dlp03.au.ibm.com (Postfix) with ESMTP id 23BCF3578053
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 02:01:00 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
        by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0FF0xJk7602444
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 02:00:59 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
        by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0FF0wXs023328
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 02:00:59 +1100
In-Reply-To: <20170113175201.GD3470@naverao1-tp.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-01-13 at 23:22 +0530, 'Naveen N. Rao' wrote:
> > That rather depends on whether the processor has a store to load forwarder
> > that will satisfy the read from the store buffer.
> > I don't know about ppc, but at least some x86 will do that.
> 
> Interesting - good to know that.
> 
> However, I don't think powerpc does that and in-register swap is likely 
> faster regardless. Note also that gcc prefers this form at higher 
> optimization levels.

Of course powerpc has a load-store forwarder these days, however, I
wouldn't be surprised if the in-register form was still faster on some
implementations, but this needs to be tested.

Ideally, you'd want to try to "optimize" load+swap or swap+store
though.

Cheers,
Ben.
