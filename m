From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 0/5] Networking cgroup controller
Date: Thu, 25 Aug 2016 12:09:20 -0400
Message-ID: <20160825160920.GC20479@htj.duckdns.org>
References: <1470876798-4024-1-git-send-email-anaravaram@google.com>
 <20160824210357.GU8185@htj.duckdns.org>
 <CAF2d9jjXxjgJU1VWDERKkv4LRvmhpjpyx7Dx76egQx43aaXtmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: corbet-T1hC0tSOHrs@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org,
        jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
        linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Wei Wang <weiwan-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org
To: Mahesh Bandewar
         =?utf-8?B?KOCkruCkueClh+CktiDgpKzgpILgpKHgpYfgpLXgpL4=?=
         =?utf-8?B?4KSwKQ==?= <maheshb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAF2d9jjXxjgJU1VWDERKkv4LRvmhpjpyx7Dx76egQx43aaXtmQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello, Mahesh.

On Thu, Aug 25, 2016 at 08:54:19AM -0700, Mahesh Bandewar (महेश बंडेवार) wrote:
> In short most of the associated problems are handled by the
> cgroup-infra / APIs while all that need separate solution in
> alternatives.  Tejun, feels like I'm advocating cgroup approach to you
> ;)

My concern here is that the proposed fixed mechanism isn't gonna be
enough.  Port range matching wouldn't scale, so we'd need some hashmap
style thing which may be too expensive for simple matches so either we
do something adaptive or have different interfaces for the two and so
on.  IOW, I think this approach is likely to replicate what iptables
have been doing with its extensions.  I don't doubt that it is one of
the workable approaches but hardly an attractive one especially at
this point.

ebpf approach does have its shortcomings for sure but mending them
seems a lot more manageable and future-proof than going with fixed but
constantly expanding set of operations.  e.g. We can add per-cgroup
bpf programs which are called only on socket creation or other major
events, or just let bpf programs which get called on bind(2), and add
some per-cgroup state variables which are maintained by cgroup code
which can be used from these bpf programs.

Thanks.

-- 
tejun
