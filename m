From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 1/5] net: Do not record sender_cpu as napi_id
 in socket receive paths
Date: Thu, 16 Mar 2017 19:55:22 -0700
Message-ID: <1489719322.28631.278.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170316183142.15806.38824.stgit@localhost.localdomain>
         <20170316183238.15806.14293.stgit@localhost.localdomain>
         <1489701936.28631.249.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAKgT0UcHgdb0Z_KvjPJuS1gtcFEi8rj2dKouUeXkuvwjopDiBQ@mail.gmail.com>
         <1489704618.28631.267.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAKgT0UeTRNxb9B5Y7mhZ4QmKrUNSYDHBbQu6=kM+6X6ETuRu8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKgT0UeTRNxb9B5Y7mhZ4QmKrUNSYDHBbQu6=kM+6X6ETuRu8g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-03-16 at 19:40 -0700, Alexander Duyck wrote:

> I don't know.  My concern here is about the cost of going through all
> that code just for something that we know shouldn't be valid.  If
> nothing else I might update sk_can_busy_loop so that it doesn't try
> busy looping on a sk_napi_id that is NR_CPU or less.

But why would that be a win ?

if napi_by_id() returns NULL, we immediately give up, (goto out;)

So why should we add a code that will add something that will not be
useful for the vast majority of the cases where the ID is valid and we
need to do the hash look up ?

Is libc trying to avoid doing syscalls like close(-1) ?
