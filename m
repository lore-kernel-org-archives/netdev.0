From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Probably bug in netfilter hashlimit extension
Date: Mon, 11 May 2015 09:35:38 -0700
Message-ID: <CAM_iQpUjnv+NA=9K=gc+NdSncgRBJtQLoQGmDn-7BsMpRbxQpw@mail.gmail.com>
References: <20150511092941.GA8739@ikki.ethgen.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Klaus+lkml@ethgen.de
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150511092941.GA8739@ikki.ethgen.ch>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Cc'ing netdev and netfilter-devel)

On Mon, May 11, 2015 at 2:29 AM, Klaus Ethgen <Klaus+lkml@ethgen.de> wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA512
>
> Recently I tried to mitigate some slow attacks via netfilter rule
> utilizing hashlimit target. I used the following specification:
>
>    -A DETECT_INVALID -m hashlimit --hashlimit-upto 10/hour --hashlimit-mode srcip --hashlimit-name attack_invalid -j RETURN
>
> Now I seen some strange stuff. The counter in
> /proc/net/ipt_hashlimit/attack_invalid only counts from 60 back to 0 and
> then the entry disappears. Than means that a rate of 10/hour will never
> ever be detected at all.
>
> On that box I use kernel 3.16.0 from debian backport to oldstable Which
> seems to be somewhat equal to 3.16.7. So maybe that bug has beed find
> earlier or is even fixed upstream. I have no easy way to upgrade that
> kernel short term as the box is productive.
>
> Shorter times like 30/hour with a slightly bigger burst (10 instead of
> the default 5) seems to work as expected but is not able to detect the
> attacks due to the slow rate.
>
> Am I the only who seen that behaviour or is that a known limitation? I
> find no such notes anywhere that there is a limit here. (Although I
> would believe that there is a high limit somewhere. But then I would
> expect them to be returend with some errno when trying to set a to high
> value.)
>
> Please keep me in Cc as I do not monitor this List that often.
>
> Regards
>    Klaus
> - --
> Klaus Ethgen                              http://www.ethgen.ch/
> pub  4096R/4E20AF1C 2011-05-16   Klaus Ethgen <Klaus@Ethgen.de>
> Fingerprint: 85D4 CA42 952C 949B 1753  62B3 79D0 B06F 4E20 AF1C
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1
>
> iQGcBAEBCgAGBQJVUHZ/AAoJEKZ8CrGAGfasiOQMAJC5FATdWhstS+60vIwn+Iyp
> 6/dprBI9zppfS9FtKvjCEYbrzmDKpTCfST5jtC7F6VRdfMeqgfFZ9wpdOk4VGJ6c
> PgpUTGN8tUrD3oLlWtd+uPIeQ5U02h2Y6Lh5YNc+iAd2fExCqixM6vExdD+5ayWy
> jcG/h7rC3rm332VTQNbAso7XLeMqiUVLwGn5CpbvW+A5kyePlVfjrONQ+fgBME7v
> xlEH4GbLgr/K2GYrJLbGcXbIAXuYHi1NyykKE3YkJIptIdTHLZmJXA79h4gGpvNj
> JoatHhMi3WpjxHNFSc8NXnmszJd+60PSNRu3hgGW5nkJQh6tFArGOsru2gIYLKt0
> HJcO0H+gHi3sYgXRl4MxzN7GxrQjJcEL/wg+kNH8MUXZVhy4wprZoxsDiSEsmyFa
> il9ZSbzbDX9ipCqeLb6fq+5XmQ+KkzGnzV0RZAbV372kDL+r2ck4K1tI+plDch/y
> 3ivFycT6NDtmPyPW1bJ2whHsLaRG1uu9VgWcEnLoFg==
> =SvVH
> -----END PGP SIGNATURE-----
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
