From: Josh Hunt <johunt@akamai.com>
Subject: Re: [PATCH v2] ipv6: Fix protocol resubmission
Date: Tue, 02 Jun 2015 09:32:09 -0500
Message-ID: <556DBE69.60904@akamai.com>
References: <1432929886-14259-1-git-send-email-johunt@akamai.com>	<5568CBCC.1080503@cogentembedded.com>	<5568DD83.8020600@akamai.com> <CALx6S34mG6HTtJ5sofLKayMgtJ9EhwCnk9RFX-He8sVBpO9ovg@mail.gmail.com> <55692250.9070500@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:49721 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759211AbbFBOcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 10:32:11 -0400
In-Reply-To: <55692250.9070500@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/29/2015 09:37 PM, Josh Hunt wrote:
> On 05/29/2015 04:48 PM, Tom Herbert wrote:
>> Hi Josh,
>>
>> Why did you need to move the resubmit label?
>
> Grabbing nhoff out of the skb's cb didn't seem relevant anymore, unless
> we're requiring the decapsulating code to update the control block
> before it returns. Also, since we are returning nexthdr with the return
> value it seems unnecessary to go through that work when we already have it.
>
> Not that there has to be symmetry here, but for example, the v4 code
> doesn't look up the protocol field again in the inner ip header. It just
> uses the protocol value returned from the protocol handler.
>
> Also, I'm skipping the pskb_pull(), which I assumed was left up to the
> decapsulating code to setup the data pointer properly before returning.
> Again, this is how the v4 code behaves.
>
> The only thing left is the idev which I'm not sure about. Could that
> change b/t calls?
>
Tom

Do you think the above is incorrect and we should just leave the 
resubmit label where it currently is? If so, do you think we should just 
bypass the nhoff/nexthdr checks and use the nexthdr value returned by 
the protocol handler?

Thanks
Josh
