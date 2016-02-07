From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 2/4] net: add rx_nohandler stat counter
Date: Sun, 07 Feb 2016 14:46:48 -0500 (EST)
Message-ID: <20160207.144648.750890874940574761.davem@davemloft.net>
References: <1454370667-2328-1-git-send-email-jarod@redhat.com>
	<1454370667-2328-3-git-send-email-jarod@redhat.com>
	<20160207113732.25a88cc4@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, linux-kernel@vger.kernel.org,
	edumazet@google.com, jiri@mellanox.com, daniel@iogearbox.net,
	tom@herbertland.com, j.vosburgh@gmail.com, vfalico@gmail.com,
	gospo@cumulusnetworks.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160207113732.25a88cc4@xeon-e3>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sun, 7 Feb 2016 11:37:32 -0800

> On Mon,  1 Feb 2016 18:51:05 -0500
> Jarod Wilson <jarod@redhat.com> wrote:
> 
>> --- a/include/uapi/linux/if_link.h
>> +++ b/include/uapi/linux/if_link.h
>> @@ -35,6 +35,8 @@ struct rtnl_link_stats {
>>  	/* for cslip etc */
>>  	__u32	rx_compressed;
>>  	__u32	tx_compressed;
>> +
>> +	__u32	rx_nohandler;		/* dropped, no handler found	*/
>>  };
>>  
>>  /* The main device statistics structure */
>> @@ -68,6 +70,8 @@ struct rtnl_link_stats64 {
>>  	/* for cslip etc */
>>  	__u64	rx_compressed;
>>  	__u64	tx_compressed;
>> +
>> +	__u64	rx_nohandler;		/* dropped, no handler found	*/
>>  };
> 
> Why was this userspace ABI change allowed?
> The stats structure is exposed to user space via netlink
> and changing the size of responses will break iproute2 commands.
> 
> The code will be expecting one size and the response will vary and
> break existing code.  Yes, the code should check the size
> of the response, but it doesn't and I am sure iproute2 is not
> the only code that does this.

Jarod, please look into this.
