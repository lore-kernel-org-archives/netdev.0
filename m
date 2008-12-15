From: Alexander Huemer <alexander.huemer@sbg.ac.at>
Subject: Re: kernel panics with net_rx_action on kernels >2.6.26
Date: Mon, 15 Dec 2008 21:11:09 +0100
Message-ID: <4946B9DD.9010105@sbg.ac.at>
References: <20081215133521.GA6697@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <20081215133521.GA6697@ff.dom.local>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On 15-12-2008 07:48, David Miller wrote:
>   
>> From: Alexander Huemer <alexander.huemer@sbg.ac.at>
>> Date: Sun, 14 Dec 2008 15:17:32 +0100
>>
>> Networking developers generally don't read the linux-net list, it is
>> for user configuration and basic questions only, not bug reports or
>> technical discussions.
>>
>> netdev is the place to report such things, and I've added that to the
>> CC:
>>
>>     
>>> one of my machines (x86) crashes under heavy network load with kernels
>>>       
>>>> 2.6.26, i tried quite everything possible between 2.6.27 and 2.6.28-rc8.
>>>>         
>>> lspci -vv: http://xx.vu/~ahuemer/lspci_vv.txt <http://xx.vu/%7Eahuemer/lspci_vv.txt>
>>> of the quad nic 2 ports are used, the machine is acting as a iptables
>>> firewall/router.
>>>
>>> kernel config (2.6.26) http://xx.vu/~ahuemer/config <http://xx.vu/%7Eahuemer/config>
>>> screenshot of the panic:
>>> http://xx.vu/~ahuemer/kernel_panic_net_rx_action.jpg <http://xx.vu/%7Eahuemer/kernel_panic_net_rx_action.jpg>
>>>
>>> as i do not have any problems with kernels <=2.6.26, i doubt that this
>>> is a hardware problem.
>>> in case of the panic, nothing is written to the system log.
>>>
>>> any hints welcome.
>>> please CC me on replies, i am not subscribed to the  mailing list.
>>>       
>
> Could you try this patch, please?
>
> Jarek P.
> ---
>
>  drivers/net/starfire.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
> index 0358809..f86d6bb 100644
> --- a/drivers/net/starfire.c
> +++ b/drivers/net/starfire.c
> @@ -1503,6 +1503,11 @@ static int __netdev_rx(struct net_device *dev, int *quota)
>  		desc->status = 0;
>  		np->rx_done = (np->rx_done + 1) % DONE_Q_SIZE;
>  	}
> +
> +	if (*quota == 0) {	/* out of rx quota */
> +		retcode = 1;
> +		goto out;
> +	}
>  	writew(np->rx_done, np->base + CompletionQConsumerIdx);
>  
>   out:
>   
thanks for the patch, jarek.
i applied it to 2.6.28-rc8.
the machine is already running under heavy network load, as before, when
the panics occur.
heavy load means high packets/second values, not high byte/second values.
if you find that necessary for testing i will find a way to pump some
gigs through the machine.
let's see what happens.
i will get back to you after a new panic or 2 days without panic.

-- 
kind regards
alex.
