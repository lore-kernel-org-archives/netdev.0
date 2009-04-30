From: =?ISO-8859-2?Q?T=F3th_L=E1szl=F3_Attila?= <panther@elte.hu>
Subject: Re: [PATCH] xt_socket: checks for the state of nf_conntrack
Date: Thu, 30 Apr 2009 22:26:24 +0200
Message-ID: <3512771A-B2D4-48F5-90A6-AF0FAA1633D5@elte.hu>
References: <1241105755-10017-1-git-send-email-panther@balabit.hu> <20090430.093909.157285653.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 8BIT
Cc: panther@balabit.hu, kaber@trash.net, mingo@elte.hu,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	hidden@sch.bme.hu, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090430.093909.157285653.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

On 2009.04.30., at 18:39, David Miller wrote:

> From: Laszlo Attila Toth <panther@balabit.hu>
> Date: Thu, 30 Apr 2009 17:35:55 +0200
>
>> xt_socket can use connection tracking, and checks whether it is a  
>> module.
>>
>> Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
>
> I don't understand why we want what this is doing....
>

Most of the time the source / destination addresses and ports of the  
packet are enough to lookup the corresponding socket. With the SNAT  
target this kind of lookup is broken. The socket match is in the  
mangle table, before nat, thus it can see only the destination address  
set by the SNAT target (this is the reply direction). If we want to  
support SNAT, we need nf_conntrack.  But this is optional, if  
connection tracking is not in the kernel, the socket match will  
compiled without it....

>> +	depends on !NF_CONNTRACK || NF_CONNTRACK
>
> This means that if NF_CONNTRACK is modular, it won't allow
> the xt_socket code to be built.
>

I checked that if NF_CONNTRACK is disabled, the socket match will be  
allowed to be built either into a module, or into vmlinuz. If  
NF_CONNTRACK is "y", it is exactly the same. If NF_CONNTRACK=m, the  
socket match can only be a module.

> However, all of this stuff should be buildable modular.

--
Attila