From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 2/3] can: fix oops caused by wrong rtnl dellink usage
Date: Tue, 28 Jun 2016 17:55:27 +0200
Message-ID: <34b61d80-6069-4ee4-a129-93d77305edae@hartkopp.net>
References: <1466673741-23115-1-git-send-email-mkl@pengutronix.de>
 <1466673741-23115-3-git-send-email-mkl@pengutronix.de>
 <e092c3e9-56f3-f765-a9ef-89697ec46e16@cogentembedded.com>
 <0e51107f-a381-6c94-0079-d0ed415d8bcc@hartkopp.net>
 <f4b685f9-a2ad-d3cc-1204-f457705467df@cogentembedded.com>
 <a1bd95b5-ea93-0e99-7784-dad393240f06@hartkopp.net>
 <874m8d7oiu.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, stable@vger.kernel.org
To: Holger Schurig <holgerschurig@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <874m8d7oiu.fsf@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/28/2016 09:36 AM, Holger Schurig wrote:
>> static void can_dellink(struct net_device *dev, struct list_head *head);
>>
>> and
>>
>> static void can_dellink(struct net_device *dev, struct list_head *head)
>> {
>> 	return;
>> }
>
> Wouldn't the canonical form be this:
>
> static void can_dellink(struct net_device *dev, struct list_head *head)
> {
> }
>
>
> - the curly braces make sure this isn't a forward definition
> - but no useless return either
>
>
> But then again, this "return" is only cosmetical.

Yes it is just coding style.

 > No compiler will
> generate any code from it.

ACK.

If you check

	~/linux$ git grep \{\ return\;

there are many occurrences of empty void functions having a 'return' 
inside the curly braces.

I think

	static void can_dellink( ... ){}

would have made it too.

Now can_dellink() just locks similar to can_newlink() some lines above.

Regards,
Oliver
