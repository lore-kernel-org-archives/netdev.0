From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH] rds: Fix inaccurate accounting of unsignaled wrs
Date: Tue, 24 Oct 2017 09:05:59 -0700
Message-ID: <e97ce8a5-4ad4-791b-2dd4-b3101999cca0@oracle.com>
References: <20171024141628.14637-1-Haakon.Bugge@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-kernel@vger.kernel.org
To: =?UTF-8?Q?H=c3=a5kon_Bugge?= <Haakon.Bugge@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024141628.14637-1-Haakon.Bugge@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/24/2017 7:16 AM, Håkon Bugge wrote:
> The number of unsignaled work-requests posted to the IB send queue is
> tracked by a counter in the rds_ib_connection struct. When it reaches
> zero, or the caller explicitly asks for it, the send-signaled bit is
> set in send_flags and the counter is reset. This is performed by the
> rds_ib_set_wr_signal_state() function.
> 
> However, this function is not always used which yields inaccurate
> accounting. This commit fixes this, re-factors a code bloat related to
> the matter, and makes the actual parameter type to the function
> consistent.
> 
> Signed-off-by: Håkon Bugge <haakon.bugge@oracle.com>
> ---
Instead of partially doing changes inside/outside helper,
can also add inline helper for solicited state like
rds_ib_set_wr_solicited_state() and use that along
with this change.

Regards,
Santosh
