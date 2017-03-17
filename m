From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 1/5] net: Do not record sender_cpu as napi_id in
 socket receive paths
Date: Thu, 16 Mar 2017 19:59:24 -0700
Message-ID: <CAKgT0UeznHgb_auisw1DsjZaw_7TuQhwL-qL0nqqLpt_4MGg_w@mail.gmail.com>
References: <20170316183142.15806.38824.stgit@localhost.localdomain>
 <20170316183238.15806.14293.stgit@localhost.localdomain> <1489701936.28631.249.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UcHgdb0Z_KvjPJuS1gtcFEi8rj2dKouUeXkuvwjopDiBQ@mail.gmail.com>
 <1489704618.28631.267.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UeTRNxb9B5Y7mhZ4QmKrUNSYDHBbQu6=kM+6X6ETuRu8g@mail.gmail.com> <1489719448.28631.279.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489719448.28631.279.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 16, 2017 at 7:57 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2017-03-16 at 19:40 -0700, Alexander Duyck wrote:
>
>> What I probably can do is go through and replace all the spots where
>> we where checking for sk_napi_id being 0, and instead replace it with
>> a check against NR_CPUS.
>
> This seems a good idea.

Right.  This is the path I am planning to go with.  It will require
about the same amount of code change but replaces those checks.  I
just have to make sure I catch all the spots where we were checking it
for 0 but that shouldn't be too difficult of an issue.
