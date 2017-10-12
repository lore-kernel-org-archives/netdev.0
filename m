From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: Re: [PATCH] [net-next] ip_tunnel: fix building with NET_IP_TUNNEL=m
Date: Thu, 12 Oct 2017 15:16:36 +0200
Message-ID: <b020dc5d-5d76-037e-a055-c93c9fefc751@6wind.com>
References: <20171011135546.3536829-1-arnd@arndb.de>
 <CAK8P3a0GDGs-iJegS2RZFtiBKU7miOuK0aujGDdBLVsvyh0Ngg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK8P3a0GDGs-iJegS2RZFtiBKU7miOuK0aujGDdBLVsvyh0Ngg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

On 10/11/2017 03:57 PM, Arnd Bergmann wrote:
> I forgot to Cc Amine, sorry.
>
> On Wed, Oct 11, 2017 at 3:55 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> When af_mpls is built-in but the tunnel support is a module,
>> we get a link failure:
>>
>> net/mpls/af_mpls.o: In function `mpls_init':
>> af_mpls.c:(.init.text+0xdc): undefined reference to `ip_tunnel_encap_add_ops'
>>
>> This adds a Kconfig statement to prevent the broken
>> configuration and force mpls to be a module as well in
>> this case.
>>
>> Fixes: bdc476413dcd ("ip_tunnel: add mpls over gre support")
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> ---
>>  net/mpls/Kconfig | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
>> index 5c467ef97311..801ea9098387 100644
>> --- a/net/mpls/Kconfig
>> +++ b/net/mpls/Kconfig
>> @@ -24,6 +24,7 @@ config NET_MPLS_GSO
>>
>>  config MPLS_ROUTING
>>         tristate "MPLS: routing support"
>> +       depends on NET_IP_TUNNEL || NET_IP_TUNNEL=n
>>         ---help---
>>          Add support for forwarding of mpls packets.
>>
>> --
>> 2.9.0
>>

Acked-by: Amine Kherbouche <amine.kherbouche@6wind.com>
