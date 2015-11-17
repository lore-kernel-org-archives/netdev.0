From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net] tcp: ensure proper barriers in lockless contexts
Date: Mon, 16 Nov 2015 20:45:25 -0500
Message-ID: <CAP=VYLoykaLLJgv00qnm7D=EfcSdF7F-9vop+Nsv2Q8a28YO0w@mail.gmail.com>
References: <1447346598.22599.21.camel@edumazet-glaptop2.roam.corp.google.com> <20151115.183703.577812988592183622.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: eric.dumazet@gmail.com, netdev <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20151115.183703.577812988592183622.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 15, 2015 at 6:37 PM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 12 Nov 2015 08:43:18 -0800
>
>> From: Eric Dumazet <edumazet@google.com>
>>
>> Some functions access TCP sockets without holding a lock and
>> might output non consistent data, depending on compiler and or
>> architecture.
>>
>> tcp_diag_get_info(), tcp_get_info(), tcp_poll(), get_tcp4_sock() ...
>>
>> Introduce sk_state_load() and sk_state_store() to fix the issues,
>> and more clearly document where this lack of locking is happening.
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>
> Applied, thanks.

Just a heads up that this breaks all arm64 builds in linux-next from
Monday; bisect says:

00fd38d938db3f1ab1c486549afc450cb7e751b1 is the first bad commit
commit 00fd38d938db3f1ab1c486549afc450cb7e751b1
Author: Eric Dumazet
<edumazet@google.com>http://kisskb.ellerman.id.au/kisskb/buildresult/12548450/
Date:   Thu Nov 12 08:43:18 2015 -0800

    tcp: ensure proper barriers in lockless contexts

Here is one of the linux-next fails:

http://kisskb.ellerman.id.au/kisskb/buildresult/12548450/

Paul.
--


> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
