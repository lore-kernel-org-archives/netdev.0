From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH 0/5] Networking cgroup controller
Date: Thu, 25 Aug 2016 11:53:13 -0700
Message-ID: <CAF2d9jhWg7e0y+Yb_2HZRsAKGHFo2iRX_nh4vKToVP3pH5419w@mail.gmail.com>
References: <1470876798-4024-1-git-send-email-anaravaram@google.com>
 <20160824210357.GU8185@htj.duckdns.org> <CAF2d9jjXxjgJU1VWDERKkv4LRvmhpjpyx7Dx76egQx43aaXtmQ@mail.gmail.com>
 <20160825160920.GC20479@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: corbet@lwn.net, lizefan@huawei.com, hannes@cmpxchg.org,
        David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        linux-doc@vger.kernel.org, cgroups@vger.kernel.org,
        linux-netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Wei Wang <weiwan@google.com>, tom@herbertland.com
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20160825160920.GC20479@htj.duckdns.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 25, 2016 at 9:09 AM, Tejun Heo <tj@kernel.org> wrote:
> Hello, Mahesh.
>
> On Thu, Aug 25, 2016 at 08:54:19AM -0700, Mahesh Bandewar (=E0=A4=AE=E0=
=A4=B9=E0=A5=87=E0=A4=B6 =E0=A4=AC=E0=A4=82=E0=A4=A1=E0=A5=87=E0=A4=B5=E0=
=A4=BE=E0=A4=B0) wrote:
>> In short most of the associated problems are handled by the
>> cgroup-infra / APIs while all that need separate solution in
>> alternatives.  Tejun, feels like I'm advocating cgroup approach to you
>> ;)
>
> My concern here is that the proposed fixed mechanism isn't gonna be
> enough.  Port range matching wouldn't scale, so we'd need some hashmap
> style thing which may be too expensive for simple matches so either we
> do something adaptive or have different interfaces for the two and so
> on.  IOW, I think this approach is likely to replicate what iptables
> have been doing with its extensions.  I don't doubt that it is one of
> the workable approaches but hardly an attractive one especially at
> this point.
>
> ebpf approach does have its shortcomings for sure but mending them
> seems a lot more manageable and future-proof than going with fixed but
> constantly expanding set of operations.  e.g. We can add per-cgroup
> bpf programs which are called only on socket creation or other major
> events, or just let bpf programs which get called on bind(2), and add
> some per-cgroup state variables which are maintained by cgroup code
> which can be used from these bpf programs.
>
Well, I haven't seen any of these yet (please point me the right place
if I missed) Especially the hooks that allows users to add per-cgroup
bpf programs that can be used in control-path (I think Daniel's recent
patches allow in data-path).

> Thanks.
>
> --
> tejun
