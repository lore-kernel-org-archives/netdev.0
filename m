From: =?ISO-8859-15?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: Fri, 11 Jul 2003 15:48:39 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0EB227.50403@kolumbus.fi>
References: <Pine.LNX.4.44.0307111446250.27865-100000@netcore.fi> <1057925366.896.24.camel@hades>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pekka Savola <pekkas@netcore.fi>, Andre Tomt <andre@tomt.net>,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mika Liljeberg <mika.liljeberg@welho.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It turns out to be the (otherwise valid) check for  IFF_LOOPBACK for 
gateway's address in ip6_route_add() that gives EINVAL for prefix::, and 
has nothing to do with iid being 0, just a coinsidence....

--Mika


Mika Liljeberg wrote:

>On Fri, 2003-07-11 at 14:48, Pekka Savola wrote:
>  
>
>>On 11 Jul 2003, Mika Liljeberg wrote:
>>    
>>
>>>Here's a valid use for subnet router anycase that isn't working.
>>>Somebody asked me how to set up 6to4, so I did a little testing.
>>>
>>>Doesn't work:
>>>
>>>hades:~# ip route add ::/0 via 2002:c058:6301::
>>>RTNETLINK answers: Invalid argument
>>>
>>>Works:
>>>
>>>hades:~# ip route add ::/0 via 2002:c058:6301::1
>>>
>>>Unfortunately the first form is what I need:
>>>
>>>hades:~# host -t AAAA 6to4.ipv6.funet.fi
>>>6to4.ipv6.funet.fi has AAAA address 2001:708:0:1::624
>>>6to4.ipv6.funet.fi has AAAA address 2002:c058:6301::
>>>      
>>>
>>I think that in this particular case, if should have configured your 
>>interface address with 2002:v4:addr::/16, of which subnet anycast router 
>>address would be 2002::.
>>    
>>
>
>Ah ok. It *is* configured with a /16. As far as my host is concerned,
>2002:c058:6301:: should be just a unicast address like any other, so
>maybe there is a IID==0 check somewhere?
>
>  
>
>>>So apparently there really is an inappropriate subnet router anycast
>>>sanity check. Please fix this!
>>>      
>>>
>>This *may* be caused by another issue too: nexthop's must be given in the
>>compatible "::192.88.99.1" format, not 2002:xxxx :-(
>>
>>I sent a patch on over a year or so ago, but it didn't gain that much 
>>enthusiasm..
>>    
>>
>
>I vote for fixing this too. :-)
>
>	MikaL
>
>-
>To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>Please read the FAQ at  http://www.tux.org/lkml/
>
>  
>
