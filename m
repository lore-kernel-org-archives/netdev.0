From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net] ip6tnl: fix use after free of fb_tnl_dev
Date: Thu, 14 Nov 2013 10:40:41 -0500
Message-ID: <CA+FuTSd5g3KHdf+jVLrrU8vLNm8bVRUvj8khJuOvzoRd4of0=w@mail.gmail.com>
References: <20131113211430.1ad3bb7d@gandalf.local.home> <1384440423-4275-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: rostedt@goodmis.org, linux-kernel <linux-kernel@vger.kernel.org>,
	stable@vger.kernel.org, gregkh@linuxfoundation.org,
	williams@redhat.com, linux-rt-users@vger.kernel.org,
	lclaudio@uudg.org, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1384440423-4275-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 14, 2013 at 9:47 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> Bug has been introduced by commit bb8140947a24 ("ip6tnl: allow to use rtnl ops
> on fb tunnel").
>
> When ip6_tunnel.ko is unloaded, FB device is delete by rtnl_link_unregister()
> and then we try to use the pointer in ip6_tnl_destroy_tunnels().
>
> Let's add an handler for dellink, which will never remove the FB tunnel. With
> this patch it will no more be possible to remove it via 'ip link del ip6tnl0',
> but it's safer.
>
> The same fix was already proposed by Willem de Bruijn <willemb@google.com> for
> sit interfaces.
>
> CC: Willem de Bruijn <willemb@google.com>
> Reported-by: Steven Rostedt <rostedt@goodmis.org>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Acked-by: Willem de Bruijn <willemb@google.com>

Also ran a test similar to the one for sit: `modprobe ip6_tunnel;
rmmod ip6_tunnel` with CONFIG_DEBUG_SLAB=y. This exposed the bug at
HEAD, completes successfully with the patch applied.
