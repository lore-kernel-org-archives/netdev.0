From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net] rds: Make sure updates to cp_send_gen can be observed
Date: Thu, 20 Jul 2017 09:50:03 -0700
Message-ID: <1b3210e2-6701-733c-f7f4-5f1ab7581a99@oracle.com>
References: <20170720102855.21961-1-Haakon.Bugge@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-kernel@vger.kernel.org
To: =?UTF-8?Q?H=c3=a5kon_Bugge?= <Haakon.Bugge@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170720102855.21961-1-Haakon.Bugge@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/20/2017 3:28 AM, Håkon Bugge wrote:
> cp->cp_send_gen is treated as a normal variable, although it may be
> used by different threads.
> 
> This is fixed by using {READ,WRITE}_ONCE when it is incremented and
> READ_ONCE when it is read outside the {acquire,release}_in_xmit
> protection.
>
There is explicit memory barrier before the value is read outside
the {acquire,release}_in_xmit so it takes care of load/store sync.

> Normative reference from the Linux-Kernel Memory Model:
> 
>      Loads from and stores to shared (but non-atomic) variables should
>      be protected with the READ_ONCE(), WRITE_ONCE(), and
>      ACCESS_ONCE().
> 
> Clause 5.1.2.4/25 in the C standard is also relevant.
> 
> Signed-off-by: Håkon Bugge <haakon.bugge@oracle.com>
> Reviewed-by: Knut Omang <knut.omang@oracle.com>
> ---
Having said that, {READ,WRITE}_ONCE usages seems to make
it clear and explicit. So its fine with me.

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
