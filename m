From: Mathias Krause <minipli@googlemail.com>
Subject: Re: [PATCH] xfrm_user: return error pointer instead of NULL
Date: Mon, 17 Sep 2012 22:15:33 +0200
Message-ID: <CA+rthh8D9oZMC9hwQkowMneb-wFG+fUoSnaD9g_auTCG0TBrWg@mail.gmail.com>
References: <1347572486-1628-1-git-send-email-minipli@googlemail.com>
	<20120917071642.GC13023@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120917071642.GC13023@secunet.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 17, 2012 at 9:16 AM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Thu, Sep 13, 2012 at 11:41:26PM +0200, Mathias Krause wrote:
>> When dump_one_state() returns an error, e.g. because of a too small
>> buffer to dump the whole xfrm state, xfrm_state_netlink() returns NULL
>> instead of an error pointer. But its callers expect an error pointer
>> and therefore continue to operate on a NULL skbuff.
>>
>> This could lead to a privilege escalation (execution of user code in
>> kernel context) if the attacker has CAP_NET_ADMIN and is able to map
>> address 0.
>
> Or it simply crashes with a NULL pointer dereference.

..while holding the xfrm_cfg_mutex, therefore effectively disabling
the XFRM netlink interface. So it's at least a DOS in that case ;)

Regards,
Mathias
