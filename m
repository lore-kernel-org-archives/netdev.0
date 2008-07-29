From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: iproute2 / match / meta bug?
Date: Tue, 29 Jul 2008 09:18:18 +0300
Message-ID: <200807290918.18866.denys@visp.net.lb>
References: <200807290843.29447.denys@visp.net.lb> <488EB07D.50406@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:53608 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914AbYG2GSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 02:18:41 -0400
In-Reply-To: <488EB07D.50406@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code is a bit out of my understanding, but

tc/em_meta.c
       num = bstrtoul(arg);
        if (num != LONG_MAX) {
                obj->kind = TCF_META_TYPE_INT << 12;
                obj->kind |= TCF_META_ID_VALUE;
                *dst = (unsigned long) num;
                return bstr_next(arg);
        }

num is always -1 in my case

If i change
        num = bstrtoul(arg);

        if (num != -1) {
                obj->kind = TCF_META_TYPE_INT << 12;
                obj->kind |= TCF_META_ID_VALUE;
                *dst = (unsigned long) num;
                return bstr_next(arg);
        }

Everything works correctly.
example:
filter parent 1: protocol all pref 49151 basic
filter parent 1: protocol all pref 49151 basic handle 0x1 flowid 1:100
  meta(rt_iif mask 0x00000000 eq 1234)



 Seems just typo?

On Tuesday 29 July 2008, Patrick McHardy wrote:
> Denys Fedoryshchenko wrote:
> > Kernel 2.6.26, iproute2 latest release. All required modules is loaded.
> > What did i miss or doing wrong?
> >
> > tc filter add dev ifb0 protocol all basic match "meta(rt_iif eq tap0)" classid 1:100 
> >
> > tc -s -d filter show dev ifb0
> > filter parent 1: protocol all pref 49152 basic
> > filter parent 1: protocol all pref 49152 basic handle 0x1 flowid 1:100
> >   meta(-1 eq -1)
> >
> > Whatever i try - it doesn't work
> > ./tc filter add dev ifb0 protocol all basic match meta \(rt_iif eq tap0\) classid 1:100
> >   
> 
> You probably need to add support for skb->iif in case the
> packet didn't went through IPv4.
> 


