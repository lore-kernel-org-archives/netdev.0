From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC 1/3] bpf/wireless: add wifimon program type
Date: Wed, 12 Apr 2017 16:27:34 +0200
Message-ID: <1492007254.2855.10.camel@sipsolutions.net>
References: <20170412110726.9689-1-johannes@sipsolutions.net>
         (sfid-20170412_130910_059795_2268F0CA)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170412110726.9689-1-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> (sfid-20170412_130910_059795_2268F0CA)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-04-12 at 13:07 +0200, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> Add a new program type for wifi monitor interfaces. This program
> type can
>  * access __sk_buff, but only skb->len
>  * call bpf_skb_load_bytes()
> 
> The program type is only enabled when something selects the new
> Kconfig symbol WANT_BPF_WIFIMON, which will be done by mac80211
> in a follow-up patch.

This works. An example BPF program is here:
https://p.sipsolutions.net/ca32264f2b705e5e.txt

I haven't really done any performance measurements and only tested it
in a virtual environment, but it's nice to see that in principle I can
get it working relatively easily.

One thing I'm not so sure about is the usage of __sk_buff.

Clearly, I need to pass the struct sk_buff internally for
bpf_skb_load_bytes() to work. However, using __sk_buff seems a bit
strange since I only let the program access the len field.

Perhaps adding a __wifi_sk_buff would work, but then clang will
probably complain if you pass that to bpf_skb_load_bytes().

The alternative will be to add any wifi fields we might need eventually
to __sk_buff, which perhaps isn't such a big deal since accesses are
optimized away anyway through convert_ctx_access.

Instead it may make more sense to just have a "wifi_info(skb, info)"
function you can call, e.g. with a structure that has various fields
and flags to see which you care about.

johannes
