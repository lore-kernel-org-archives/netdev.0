From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 2/7] vxlan: simplify exception handling
Date: Thu, 10 Nov 2016 10:47:03 +0100
Message-ID: <20161110104703.7386ab29@griffin>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
        <1478371557-71888-3-git-send-email-pshelar@ovn.org>
        <20161109171018.69d08ff9@griffin>
        <CAOrHB_AkVXDOaFKy_-ccRc--=wXG14TLfoC6Vc4HSBgjbDm3sA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58996 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752760AbcKJJrH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 04:47:07 -0500
In-Reply-To: <CAOrHB_AkVXDOaFKy_-ccRc--=wXG14TLfoC6Vc4HSBgjbDm3sA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Nov 2016 19:33:24 -0800, Pravin Shelar wrote:
> I have moved the dst error handling to vxlan_build_skb(), which is
> releasing the dst entry.

Hmm, right, I missed that. But it's weird. The previous logic was
confusing (skb is freed in case of error but not otherwise), I'm with
you on this change. But having the same confusing logic with dst_entry
instead doesn't improve things.

Could we free both skb and dst_entry from the caller?

Thanks,

 Jiri
