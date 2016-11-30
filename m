From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next V2 1/7] net/mlx5e: Implement Fragmented Work
 Queue (WQ)
Date: Wed, 30 Nov 2016 18:26:56 +0100 (CET)
Message-ID: <alpine.LFD.2.20.1611301822410.8710@schleppi>
References: <1480521583-12755-1-git-send-email-saeedm@mellanox.com> <1480521583-12755-2-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Tariq Toukan <tariqt@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:51804 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1758307AbcK3R1E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 12:27:04 -0500
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAUHNeo8036547
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 12:27:03 -0500
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com [195.75.94.104])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2722hgjcnc-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 12:27:03 -0500
Received: from localhost
        by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <sebott@linux.vnet.ibm.com>;
        Wed, 30 Nov 2016 17:27:01 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
        by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3C9141B08072
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 17:29:20 +0000 (GMT)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
        by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAUHQwSh15925632
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 17:26:58 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
        by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAUHQvZF031319
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 10:26:57 -0700
In-Reply-To: <1480521583-12755-2-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, 30 Nov 2016, Saeed Mahameed wrote:
> From: Tariq Toukan <tariqt@mellanox.com>
> 
> Add new type of struct mlx5_frag_buf which is used to allocate fragmented
> buffers rather than contiguous, and make the Completion Queues (CQs) use
> it as they are big (default of 2MB per CQ in Striding RQ).
> 
> This fixes the failures of type:
> "mlx5e_open_locked: mlx5e_open_channels failed, -12"
> due to dma_zalloc_coherent insufficient contiguous coherent memory to
> satisfy the driver's request when the user tries to setup more or larger
> rings.

Thanks for that patch! I can confirm that this fixes the lage allocation
issue.

Regards,
Sebastian
