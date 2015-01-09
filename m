From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net v2] ipv6: Prevent ipv6_find_hdr() from returning ENOENT
 for valid non-first fragments
Date: Fri, 09 Jan 2015 18:53:06 +0900
Message-ID: <54AFA502.8090701@miraclelinux.com>
References: <CAFB3abzM2ApxMH6C7vSDJ8JikKEkE46bOH3jbsis2NiF-ieUxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, linux-kernel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netfilter-devel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Rahul Sharma <rsharma@arista.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFB3abzM2ApxMH6C7vSDJ8JikKEkE46bOH3jbsis2NiF-ieUxA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Rahul Sharma wrote:
> ipv6_find_hdr() currently assumes that the next-header field in the
> fragment header of the non-first fragment is the "protocol number of
> the last header" (here last header excludes any extension header
> protocol numbers ) which is incorrect as per RFC2460. The next-header
> value is the first header of the fragmentable part of the original
> packet (which can be extension header as well).
> This can create reassembly problems. For example: Fragmented
> authenticated OSPFv3 packets (where AH header is inserted before the
> protocol header). For the second fragment, the next header value in
> the fragment header will be NEXTHDR_AUTH which is correct but
> ipv6_find_hdr will return ENOENT since AH is an extension header
> resulting in second fragment getting dropped. This check for the
> presence of non-extension header needs to be removed.
>
> Signed-off-by: Rahul Sharma <rsharma@arista.com>

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
