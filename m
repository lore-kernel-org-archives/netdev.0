From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next resend v4 5/7] tuntap: multiqueue support
Date: Thu, 01 Nov 2012 13:04:23 +0800
Message-ID: <509202D7.3090401@redhat.com>
References: <1351491351-11477-1-git-send-email-jasowang@redhat.com> <1351491351-11477-6-git-send-email-jasowang@redhat.com> <20121031.141618.286962451107179252.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, maxk@qualcomm.com,
	edumazet@google.com, krkumar2@in.ibm.com,
	ernesto.martin@viasat.com, haixiao@juniper.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121031.141618.286962451107179252.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/01/2012 02:16 AM, David Miller wrote:
> From: Jason Wang <jasowang@redhat.com>
> Date: Mon, 29 Oct 2012 14:15:49 +0800
>
>> @@ -110,6 +110,11 @@ struct tap_filter {
>>   	unsigned char	addr[FLT_EXACT_COUNT][ETH_ALEN];
>>   };
>>   
>> +/* 1024 is probably a high enough limit: modern hypervisors seem to support on
>> + * the order of 100-200 CPUs so this leaves us some breathing space if we want
>> + * to match a queue per guest CPU. */
> Please don't format comments like this.  Put that final "*/" on it's
> own line.
>
> I'm really perplexed how you can get it right elsewhere in your
> patches, and then botch it up only in a few select locations :-/

Sorry about this, some parts were copy paste from the comments of 
reviewer. I will post a new version to fix them all.
>> +/* We try to identify a flow through its rxhash first. The reason that
>> + * we do not check rxq no. is becuase some cards(e.g 82599), chooses
>> + * the rxq based on the txq where the last packet of the flow comes. As
>> + * the userspace application move between processors, we may get a
>> + * different rxq no. here. If we could not get rxhash, then we would
>> + * hope the rxq no. may help here.
>> + */
> For example, this one is done right.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
