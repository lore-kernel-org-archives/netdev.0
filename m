From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Subject: Re: [PATCH 00/15] RDS: connection scalability and performance
 improvements
Date: Sun, 20 Sep 2015 11:37:52 +0300
Message-ID: <55FE7060.6010205@dev.mellanox.co.il>
References: <1442703892-26692-1-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
To: Santosh Shilimkar <santosh.shilimkar@oracle.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34935 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964AbbITIhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 04:37:33 -0400
Received: by wicge5 with SMTP id ge5so79184293wic.0
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 01:37:32 -0700 (PDT)
In-Reply-To: <1442703892-26692-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/20/2015 2:04 AM, Santosh Shilimkar wrote:
> This series addresses RDS connection bottlenecks on massive workloads and
> improve the RDMA performance almost by 3X. RDS TCP also gets a small gain
> of about 12%.
>
> RDS is being used in massive systems with high scalability where several
> hundred thousand end points and tens of thousands of local processes
> are operating in tens of thousand sockets. Being RC(reliable connection),
> socket bind and release happens very often and any inefficiencies in
> bind hash look ups hurts the overall system performance. RDS bin hash-table
> uses global spin-lock which is the biggest bottleneck. To make matter worst,
> it uses rcu inside global lock for hash buckets.
> This is being addressed by simply using per bucket rw lock which makes the
> locking simple and very efficient. The hash table size is also scaled up
> accordingly.
>
> For RDS RDMA improvement, the completion handling is revamped so that we
> can do batch completions. Both send and receive completion handlers are
> split logically to achieve the same. RDS 8K messages being one of the
> key usecase, mr pool is adapted to have the 8K mrs along with default 1M
> mrs. And while doing this, few fixes and couple of bottlenecks seen with
> rds_sendmsg() are addressed.

Hi Santosh,

I think that can get a more effective code review if you CC the
Linux-rdma mailing list.

Sagi.
