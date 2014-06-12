From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [-next] Regression: ssh log in slowdown
Date: Thu, 12 Jun 2014 13:28:18 +0200
Message-ID: <CAMuHMdUzd92Tu+f+-iwQs2C__rjBQX8kSq2u-WNN6VyQNSUSVg@mail.gmail.com>
References: <CAMuHMdU6rrpx6xFw71HKexDJUZtfFtL+um6dxZ=EaycgVO312A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux-Next <linux-next@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdU6rrpx6xFw71HKexDJUZtfFtL+um6dxZ=EaycgVO312A@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cc netdev@vger.kernel.org

On Thu, Jun 12, 2014 at 1:26 PM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> When logging in remotely using ssh, there's now a 10 second delay,
> cfr. the "ssh -v" output below:
>
> debug1: ssh_ecdsa_verify: signature correct
> debug1: SSH2_MSG_NEWKEYS sent
> debug1: expecting SSH2_MSG_NEWKEYS
> debug1: SSH2_MSG_NEWKEYS received
> debug1: Roaming not allowed by server
> debug1: SSH2_MSG_SERVICE_REQUEST sent
> debug1: SSH2_MSG_SERVICE_ACCEPT received
>
> ----- 10 s delay ---
>
> debug1: Authentications that can continue: publickey,password
> debug1: Next authentication method: publickey
>
> Wireshark doesn't show anything suspicious, just that there's a 10 s gap
> before I receive an "encrypted response packet" on the client.
>
> Hardware is r8a7791/koelsch, using sh_eth.
>
> I bisected this to
> commit 7e3cead5172927732f51fde77fef6f521e22f209
> Author: Tom Herbert <therbert@google.com>
> Date:   Tue Jun 10 18:54:19 2014 -0700
>
>     net: Save software checksum complete
>
>     In skb_checksum complete, if we need to compute the checksum for the
>     packet (via skb_checksum) save the result as CHECKSUM_COMPLETE.
>     Subsequent checksum verification can use this.
>
>     Also, added csum_complete_sw flag to distinguish between software and
>     hardware generated checksum complete, we should always be able to trust
>     the software computation.
>
>     Signed-off-by: Tom Herbert <therbert@google.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> Reverting this commit fixes the issue.
>
> Anyone with a clue?
>
> Thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvald
