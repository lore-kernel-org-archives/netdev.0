From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/tun: fix ioctl() based info leaks
Date: Sun, 29 Jul 2012 23:34:18 -0700 (PDT)
Message-ID: <20120729.233418.689324134181158219.davem@davemloft.net>
References: <CAFLxGvwUNxOn3vRLdJeS6hVZ_Oko0_QPZfLWAe+ztCHGdqBFOw@mail.gmail.com>
	<1343627114-17899-1-git-send-email-minipli@googlemail.com>
	<1343629340.2626.13268.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: minipli@googlemail.com, richard.weinberger@gmail.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50871 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832Ab2G3GeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 02:34:19 -0400
In-Reply-To: <1343629340.2626.13268.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 30 Jul 2012 08:22:20 +0200

> On Mon, 2012-07-30 at 07:45 +0200, Mathias Krause wrote:
>> The tun module leaks up to 36 bytes of memory by not fully initializing
>> a structure located on the stack that gets copied to user memory by the
>> TUNGETIFF and SIOCGIFHWADDR ioctl()s.
>> 
>> Signed-off-by: Mathias Krause <minipli@googlemail.com>
>> ---
>> v2:
>> - removed braces around else branch
>> - minor adjustment of the commit message
>> 
>>  drivers/net/tun.c |    4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>> 
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index 987aeef..01255ff 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -1252,9 +1252,11 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
>>  	int vnet_hdr_sz;
>>  	int ret;
>>  
>> -	if (cmd == TUNSETIFF || _IOC_TYPE(cmd) == 0x89)
>> +	if (cmd == TUNSETIFF || _IOC_TYPE(cmd) == 0x89) {
>>  		if (copy_from_user(&ifr, argp, ifreq_len))
>>  			return -EFAULT;
>> +	} else
>> +		memset(&ifr, 0, sizeof(ifr));
>>  
>>  	if (cmd == TUNGETFEATURES) {
>>  		/* Currently this just means: "what IFF flags are valid?".
> 
> 
> Actually braces were better
> 
> vi +169 Documentation/CodingStyle
> 
> This does not apply if only one branch of a conditional statement is a
> single
> statement; in the latter case use braces in both branches:
> 
> if (condition) {
>         do_this();
>         do_that();
> } else {
>         otherwise();
> }

Ok I'll fix this up myself.
