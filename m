From: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] openvswitch: Orphan frags before sending to
 userspace via Netlink to avoid guest stall
Date: Fri, 7 Mar 2014 09:38:31 -0800
Message-ID: <CALnjE+pkTyHycgH+xZ+Uv=SXmoWmeUJBYa6uqWjy0L_3xG3FZg@mail.gmail.com>
References: <1393615016-9187-1-git-send-email-zoltan.kiss@citrix.com>
 <5318ABC0.4040307@citrix.com>
 <CALnjE+rWc=n_F+1jSLQtPrgKSvvxONEkkYxWEHon2_KVNG9z3Q@mail.gmail.com>
 <5319BBAE.7030109@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org
To: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <5319BBAE.7030109-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
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

On Fri, Mar 7, 2014 at 4:29 AM, Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org> wrote:
> On 07/03/14 04:46, Pravin Shelar wrote:
>>
>> On Thu, Mar 6, 2014 at 9:09 AM, Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
>> wrote:
>>>
>>> Do you have any feedback on this? I'm also adding KVM list as they might
>>> be
>>> interested in this.
>>>
>>> Zoli
>>>
>>>
>>> On 28/02/14 19:16, Zoltan Kiss wrote:
>>>>
>>>>
>>>> The kernel datapath now switched to zerocopy Netlink messages, but that
>>>> also
>>>> means that the pages on frags array are sent straight to userspace. If
>>>> those
>>>> pages came outside the kernel, we have to swap them out with local
>>>> copies.
>>>>
>>>> Signed-off-by: Zoltan Kiss <zoltan.kiss-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
>>
>>
>> I do not think this is required, netlink zero copy only maps
>> pre-allocated buffers to user-space.
>
> How do you mean "pre-allocated"? By who?
>
by netlink, ref. netlink_alloc_skb().

> As far as I've seen the skb in this function came straight from the device
> (vif in our case), and skb_zerocopy just copy the frags to user_skb, which
> is sent to the userspace. Those frags contain pages from guest, and it's a
> bad idea to pass them to userspace: e.g if userspace dies in the meantime,
> what happens with them? Also, in Xen's case they are actually not mapped to
> userspace, so accessing them can lead to garbage.
>
AFAIK Netlink does not handle skb-frags for zero-copy case.
