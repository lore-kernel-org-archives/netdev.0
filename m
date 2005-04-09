From: Indrek Kruusa <indrek.kruusa@tuleriit.ee>
Subject: Re: Fw: Re: 2.6.12-rc2-mm2
Date: Sat, 09 Apr 2005 18:07:52 +0300
Message-ID: <4257EFC8.3060804@tuleriit.ee>
References: <E1DK25V-0005Ye-00@gondolin.me.apana.org.au>
Reply-To: indrek.kruusa@tuleriit.ee
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DK25V-0005Ye-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>Andrew Morton <akpm@osdl.org> wrote:
>  
>
>>dmesg is not clean though:
>>
>>TCP: time wait bucket table overflow
>>TCP: time wait bucket table overflow
>>TCP: time wait bucket table overflow
>>printk: 392 messages suppressed.
>>
>>What I did:
>>- "bombing" httpd with JMeter (from another computer)
>>    
>>
>
>This is normal.  The number of TCP connections held by
>your server in the TIME_WAIT state is exceeding
>tcp_max_tw_buckets.
>
>Check out tcp(7) on what this means and how it may or
>may not be a problem for you.
>  
>


This poor Celeron machine has only 128MB RAM and tcp_max_tw_buckets were 
calculated (ipv4/tcp.c) to be 16384. I have found
that increasing this number by 2048 (that's 12.5%) = 18432 is enough to 
not get this overflow warning again (load average was over 90). Some 
other facts:

- my current machine has 512MB RAM and calculated tcp_max_tw_buckets is 
180000 (!)
- from Documentation/networking/ip-sysctl.txt: This limit exists only to 
prevent simple DoS attacks


I believe that those values are somewhat miscalculated. At least by 
changing calculation for machines with low memory a bit you will get 
some defence against poor shouting students who had to build 
load-balancing web-clusters ;)

thanks,
Indrek
