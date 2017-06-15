From: =?utf-8?B?5Lil5rW35Y+M?= <yanhaishuang@cmss.chinamobile.com>
Subject: Re: [PATCH] ip6_tunnel: Correct tos value in collect_md mode
Date: Thu, 15 Jun 2017 08:58:41 +0800
Message-ID: <142A1EF8-2274-47FD-BA8B-DFF99308E366@cmss.chinamobile.com>
References: <1497408497-1473-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <9E61EADF-769B-431A-81EA-ADBAAD32ABD3@cmss.chinamobile.com>
 <20170614152839.38406ce2@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Patrick McHardy <kaber@trash.net>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Peter Dawson <petedaws@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170614152839.38406ce2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On 14 Jun 2017, at 1:28 PM, Peter Dawson <petedaws@gmail.com> wrote:
> 
> On Wed, 14 Jun 2017 10:54:31 +0800
> 严海双 <yanhaishuang@cmss.chinamobile.com> wrote:
> 
> 
>>> Changes since v2:
>>> * mask key->tos with RT_TOS() suggested by Daniel
> 
> Can you help me understand the rationale for this change? Is there are bug introduced by dsfield = ip6_tclass(key->label); ?
> 
> The RT_TOS masks out 4bits of the 8bit tos field in accordance with RFC1349 (obsoleted by RFC2474). IPv6 does not have a TOS field. So it dosen't make sense to apply a TOS value to the outer header of an IPv6 tunnel.
> 
> 

Hi, Peter

Here the tos also means Traffic Class in IPv6, see the define in struct ip_tunnel_key:

u8          tos;        /* TOS for IPv4, TC for IPv6 */

RT_TOS mask is suggested by Daniel, please refer to the implement in vxlan or geneve code:

fl6.flowlabel = ip6_make_flowinfo(RT_TOS(tos), label);

Thanks.
