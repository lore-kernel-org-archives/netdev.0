From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH net-next 2/2] net:add socket option for low latency polling
Date: Wed, 12 Jun 2013 09:39:12 +0300
Message-ID: <51B81790.5040806@linux.intel.com>
References: <20130611142415.17879.75569.stgit@ladj378.jer.intel.com>  <20130611142438.17879.6389.stgit@ladj378.jer.intel.com> <1370982272.1954.8.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370982272.1954.8.camel@bwh-desktop.uk.level5networks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/06/2013 23:24, Ben Hutchings wrote:
> On Tue, 2013-06-11 at 17:24 +0300, Eliezer Tamir wrote:
>> adds a socket option for low latency polling.
>> This allows overriding the global sysctl value with a per-socket one.
> [...]
>> --- a/net/core/sock.c
>> +++ b/net/core/sock.c
>> @@ -913,6 +913,23 @@ set_rcvbuf:
>>   		sock_valbool_flag(sk, SOCK_SELECT_ERR_QUEUE, valbool);
>>   		break;
>>
>> +#ifdef CONFIG_NET_LL_RX_POLL
>> +	case SO_LL:
>> +		if (!capable(CAP_NET_ADMIN))
>> +			ret = -EACCES;
> [...]
>
> Failed capability checks normally result in EPERM whereas EACCES usually
> results from a file permission/ACL/label check.

OK

> Perhaps unprivileged users should be allowed to set a value as long as
> it's less than or equal to the global value?

I thought of allowing to disable even if you are not privileged, but 
this sounds better.

Thanks!
