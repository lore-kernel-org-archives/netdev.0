From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: Sending ipv6 packets from a kernel module
Date: Mon, 21 May 2007 12:58:32 -0400
Message-ID: <4651CFB8.5090401@hp.com>
References: <46512159.8080501@dsto.defence.gov.au> <20070521135016.GA452@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Anton <Anton.Uzunov@dsto.defence.gov.au>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:39958 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755131AbXEUQ6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 12:58:40 -0400
In-Reply-To: <20070521135016.GA452@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neil Horman wrote:
> On Mon, May 21, 2007 at 02:04:33PM +0930, Anton wrote:
>> Hi all,
>>
>> Please excuse me if the following question has already been asked on the 
>> mailing list, I am a little new to this.
>>
>> I am trying to send IPv6 packets from a kernel module. As far as I 
>> understand, I would have to use the ip6_output() function, and this 
>> function is certainly present in the net/ipv6/ip6_output.c file (on my
>> 2.6.18 kernel). Unfortunately, the function is not exported from the
>> IPv6 module and so my kernel module is unable to use it. Has anyone 
>> encountered such a problem before, and if not, does anyone know what is 
>> required for me to push a sk_buff into the IP stack for transmission 
>> (from a kernel module)?
>> Any ideas would be appreciated!
>>
>> Regards,
>> Anton
>>
> No, you'll probably want to use something like kernel_sendmsg to send what you
> want, passing in a socket created with something like sock_create_kern.
> 
> Regards
> Neil
> 

You can also use ip6_xmit assuming the module has performed the necessary route lookups.

-vlad
