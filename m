From: Mike_Phillips@URSCorp.com
Subject: Re: [PATCH] (5/6) ibmtr -- probe2
Date: Mon, 20 Oct 2003 21:50:38 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF4E189CBC.0F8473E2-ON84256DC6.0002006F-84256DC6.0004A2F2@urscorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>The problem with the structures was a BUG in the existing code!
>The PCMCIA code was setting dev->priv to a structure:

<snip>

AAARRRGGH, it got screwed up somewhere in the past, during 2.5 or 2.6
somewhere. Take a look at 2.4.22, dev-priv gets set to &info->ti. *sigh*,
apologies, it doesn't help when the code you're looking at in the main tree
isn't the same as my dev tree and what I remember. (Wonder if it works at
all in 2.6, if it doesn't that shows just how many people are actually
testing it ;)

I *can* see what you're trying to do with the rest of the patch, although I
need to grab net-2.5-exp to fully see how this all works. There's parts of
the patch where I can see where the code was grabbed from but doesn't make
total sense yet (like testing for #ifndef PCMCIA in ibmtr_probe when
another part of the patch removed the call to ibmtr_probe from the pcmcia
driver.)

Bear with me, I think there's probably a cleaner solution.

pcmcia allocating its own dev structures is a right pain, would be nice if
this could go away too and it could all be done from the probe2 api.

Mike
