From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] proc connector: reject unprivileged listener bumps
Date: Wed, 27 Feb 2013 13:08:59 -0500 (EST)
Message-ID: <20130227.130859.1239743436839936054.davem@davemloft.net>
References: <20130226073225.GA15489@www.outflux.net>
	<20130226172441.GA6312@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: keescook@chromium.org, linux-kernel@vger.kernel.org,
	zbr@ioremap.net, netdev@vger.kernel.org, matthltc@us.ibm.com
To: matthltc@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130226172441.GA6312@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matt Helsley <matthltc@linux.vnet.ibm.com>
Date: Tue, 26 Feb 2013 09:24:41 -0800

> On Mon, Feb 25, 2013 at 11:32:25PM -0800, Kees Cook wrote:
>> While PROC_CN_MCAST_LISTEN/IGNORE is entirely advisory, it was possible
>> for an unprivileged user to turn off notifications for all listeners by
>> sending PROC_CN_MCAST_IGNORE. Instead, require the same privileges as
>> required for a multicast bind.
>> 
>> Signed-off-by: Kees Cook <keescook@chromium.org>
>> Cc: Evgeniy Polyakov <zbr@ioremap.net>
>> Cc: Matt Helsley <matthltc@us.ibm.com>
>> Cc: stable@vger.kernel.org
>> ---
>>  drivers/connector/cn_proc.c |    8 ++++++++
>>  1 file changed, 8 insertions(+)
>> 
>> diff --git a/drivers/connector/cn_proc.c b/drivers/connector/cn_proc.c
>> index fce2000..1110478 100644
>> --- a/drivers/connector/cn_proc.c
>> +++ b/drivers/connector/cn_proc.c
>> @@ -313,6 +313,12 @@ static void cn_proc_mcast_ctl(struct cn_msg *msg,
>>  	    (task_active_pid_ns(current) != &init_pid_ns))
>>  		return;
>> 
>> +	/* Can only change if privileged. */
> 
> I think this comment doesn't tell us anything above and beyond the
> what capability check already tells us. I think you could improve it
> by noting that since the connector is multicast and not namespace-safe
> it's not yet appropriate to use ns_capable() here.
> 
> Acked-by: Matt Helsley <matthltc@us.ibm.com>

Applied.
