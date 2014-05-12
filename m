From: Xufeng Zhang <xufeng.zhang@windriver.com>
Subject: Re: [RFC][PATCH] af_key: return error when meet errors on sendmsg()
 syscall
Date: Mon, 12 May 2014 14:05:09 +0800
Message-ID: <53706495.1050303@windriver.com>
References: <1399614455-10551-1-git-send-email-xufeng.zhang@windriver.com> <20140512.011141.74073195599318391.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140512.011141.74073195599318391.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/12/2014 01:11 PM, David Miller wrote:
>
>> So it makes sense to return errors for send() syscall.
>>
>> Signed-off-by: Xufeng Zhang<xufeng.zhang@windriver.com>
>>      
> I disagree.
>
> If pfkey_error() is successful, the error will be reported in the AF_KEY
> message that is broadcast, there is no reason for sendmsg to return an
> error.  The message was sucessfully sent, there was no problem with it's
> passage into the AF_KEY layer.
>
> Like netlink, operational responses come in packets, not error codes.
>
> However, if pfkey_error() fails, we must do pass back the original
> error code because it's a last ditch effort to prevent information
> from being lost.
>
> That's why 'err' must be preserved when pfkey_error() returns zero.
>    

I know what you mean, but isn't the kernel API aimed to facilitate the
implementation of user space?
Since send the message to the kernel and receive the error report message
are asynchronous, I don't think it's easy to recover from the EINTR error
by parsing the error report message.


Thanks,
Xufeng
