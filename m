From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Subject: Re: ax25 rose Re: kernel panic linux-2.6.27-rc7
Date: Wed, 01 Oct 2008 00:49:02 +0200
Message-ID: <48E2ACDE.30406@free.fr>
References: <48DF7D51.1010507@free.fr> <20080929123036.GA16954@ff.dom.local> <48E1F417.7080304@free.fr> <20080930101030.GA6290@ff.dom.local> <20080930111733.GB6290@ff.dom.local> <48E29337.2080400@free.fr> <20080930213052.GA6449@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g19.free.fr ([212.27.42.27]:36894 "EHLO smtp1-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753123AbYI3WtF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2008 18:49:05 -0400
In-Reply-To: <20080930213052.GA6449@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek,

With the patch #2, there have been only one reboot after the machine was 
frozen. I did not notice that was happening for there was no kernel 
panic message but a frozen display only.
Then I could only write down partially the values displayed after 
AX25_DBG: c446c220, c..... 3, 5, 240
Second number was not 000000 as it is most of the time.
The machine rebooted after the usual 60 seconds delay and since then 
there was no kernel panic.
This is the first time kernel 2.6.27-rc7 does not panic within a minute.
The system is up since about 20 minutes now with frequent AX25_DBG messages.

I am sorry that I must go to sleep now to be at work early in the morning.
I will be away from my Linux box for a few days.
Then we should probably interrupt this interesting bug hunting.
I will send more results when I am back.

Thank you and best regards,

Bernard



Jarek Poplawski wrote:
> On Tue, Sep 30, 2008 at 10:59:35PM +0200, Bernard Pidoux F6BVP wrote:
>> Jarek,
>>
>> Yes I am using n2kpci/8390 driver.
>> The second patch seems to have removed the inconsistent lock state.
> 
> It's fine: this patch is only for this one (simpler) problem.
> 
>> But the kernel panic still occured systematically.
>> However I did not catch netconsole messages since the patch prevented  
>> transmission to remote console via ethernet.
>>
>> Before the machine rebooted I only noted the following information at  
>> the bottom of the local console page :
>>
>> EIP: [<.....>] datagram_poll + 0xe9/0xf0
>>
>> Does it help ?
> 
> Probably the beginning of the same oops as before.
> 
> Here is a debugging patch #2, which should give us more details.
> Apply after reverting debugging patch #1 (lib8390 patch should stay).
> Alas the oops in datagram_poll is still possible.
> 
> Thanks,
> Jarek P.
> 
> ---
> 
>  net/core/sock.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 2d358dd..3ad8eaa 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -960,6 +960,15 @@ void sk_free(struct sock *sk)
>  {
>  	struct sk_filter *filter;
>  
> +	if (sk->sk_socket) {
> +		printk("AX25_DBG: %p, %p, %u, %u, %u, %p\n", sk, sk->sk_socket,
> +			 sk->sk_family, sk->sk_type, sk->sk_protocol, sk->sk_socket->sk);
> +		if (sk->sk_family == 3 && sk->sk_type == 5 && sk->sk_protocol == 240) {
> +			WARN_ON_ONCE(1);
> +			sock_orphan(sk);
> +		}
> +	}
> +
>  	if (sk->sk_destruct)
>  		sk->sk_destruct(sk);
>  
> 
> 
