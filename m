From: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] openvswitch: Orphan frags before sending to
 userspace via Netlink to avoid guest stall
Date: Fri, 7 Mar 2014 10:41:08 -0800
Message-ID: <CALnjE+oMCexif_D3e41F8o9DXn=v6hshj3y-g+bLPoCWtSELww@mail.gmail.com>
References: <1393615016-9187-1-git-send-email-zoltan.kiss@citrix.com>
 <5319F272.1070101@redhat.com>
 <CALnjE+q=fejHPsjVj9+jnypJCUHfCDFc553U48WR48Tjcf3FZw@mail.gmail.com>
 <531A0911.4040304@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org
To: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <531A0911.4040304-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Fri, Mar 7, 2014 at 9:59 AM, Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On 03/07/2014 06:28 PM, Pravin Shelar wrote:
>>
>> Problem is mapping SKBTX_DEV_ZEROCOPY pages to userspace. skb_zerocopy
>> is not doing that.
>>
>> Unless I missing something, Current netlink code can not handle
>> skb-frags with zero copy. So we have to copy skb anyways and no need
>> to orphan-frags here.
>> If you are planning on handling skb-frags without copying then
>> skb_orphan_frags should be done in netlink.
>
>
> If you look at the second part of skb_zerocopy() this is exactly what
> it is doing unless the target skb has sufficient linear space
> preallocated. At least unless mmap is enabled in which case we would
> have to copy again until we have implemented a way to pass page refs
> via the nl ring buffer.
>

What is problem with passing page ref with get_page() to new skb as
long as it is accessed kernel?

I think we should set SKBTX_DEV_ZEROCOPY flag for new skb in
skb_zerocopy() to track such pages but no need call
skb_orphan_frags().

> So I think Zoltan is correct in orphaning frags that come from f.e.
> a tun device via zerocopy_sg_from_iovec().
