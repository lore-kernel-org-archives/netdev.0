From: Aidas Kasparas <a.kasparas@gmc.lt>
Subject: Re: [Ipsec-tools-devel] ipv4/ipv6 forwarding check
Date: Fri, 29 Oct 2004 11:09:25 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4181FAB5.4010005@gmc.lt>
References: <E1CNR73-0007X6-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: latten@austin.ibm.com, ipsec-tools-devel@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CNR73-0007X6-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Herbert Xu wrote:
> Aidas Kasparas <a.kasparas@gmc.lt> wrote:
> 
>>       Meanwhile, I would like to recomend to abstain from upgrading to 
>>anything above 2.6.9.
> 
> 
> Doesn't sound like a good idea as that's a massive security hole.
> 
> Racoon with a pre-2.6.9 kernel will allow source addresses to come
> through the IPsec tunnel even if the violate IPsec policies.

Ok, my dear coleagues admins, decide for yourself. Facts are:

If you upgrade, your system will not work.

If you do not upgrade, and on host c.c.c.c you have policy
a.a.a.a b.b.b.b any -P in esp/.../

where b.b.b.b is address different from any interface address of host 
with address c.c.c.c and
1) some party h.h.h.h will be able to spoof packet to look from a.a.a.a 
  to b.b.b.b;
2) transport that packet to c.c.c.c
3) that packet will not be filtered out by rp_filter on c.c.c.c
then kernel will pass that packet through to b.b.b.b, even if that 
packet is not protected by esp.

It is possible to prevent that from happening by marking esp packets and 
later accepting for forwarding only marked packets from a.a.a.a to 
b.b.b.b using iptables. Yes, I have insisted in the past this is not 
necessary. I was wrong. I'm sorry. I did not knew about this kernel's 
feature.

[Have I missed any other case?]

Which way to choose for the short term -- decission is after you.


-- 
Aidas Kasparas
IT administrator
GM Consult Group, UAB
