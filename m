From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: double-check me?
Date: Sun, 17 Aug 2003 18:31:02 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F400226.1080006@pobox.com>
References: <3F3FBF50.8070207@pobox.com> <m3n0e8uhl4.fsf@defiant.pm.waw.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Krzysztof Halasa <khc@pm.waw.pl>
In-Reply-To: <m3n0e8uhl4.fsf@defiant.pm.waw.pl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Krzysztof Halasa wrote:
> Jeff Garzik <jgarzik@pobox.com> writes:
> 
> 
>>Maybe you guys can spot something I'm missing here.  alloc_netdev is
>>supposed to guarantee that dev->priv is aligned by 32 bytes:
>>
>>         struct net_device *dev;
>>
>>         if (sizeof_priv)
>>                 dev->priv = (void *) (((long)(dev + 1) + 31) & ~31);
>>
>>
>>Now... shouldn't that last line of code be "dev + 1 + sizeof(*dev)" ?
>>
>>It seems to work 2.[456] for a long time, so I am doubting
>>myself... surely it would have caused memory corruption or something
>>by now if I have really found a bug.
> 
> 
> Looks ok... not very readable, though.
> 
> dev + 1 = ((u8*)dev) + sizeof(dev) = pointer to end of net_device struct.


C pointer arithmatic.  Ok, duh, thanks :)

	Jeff, too used to void pointer arith
