From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [patch net-next v3] tc: introduce OpenFlow classifier
Date: Sun, 12 Apr 2015 17:12:13 -0700
Message-ID: <20150413001212.GA1656@Alexeis-MBP.westell.com>
References: <20150410124517.GC2021@nanopsycho.orion>
 <20150411161223.GA802@Alexeis-MBP.westell.com>
 <20150412075351.GA2112@nanopsycho.orion>
 <20150412.194443.1571071793033525091.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us, netdev@vger.kernel.org, jhs@mojatatu.com,
	tgraf@suug.ch, jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:36297 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045AbbDMAMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 20:12:18 -0400
Received: by igblo3 with SMTP id lo3so33358872igb.1
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 17:12:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150412.194443.1571071793033525091.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 12, 2015 at 07:44:43PM -0400, David Miller wrote:
> From: Jiri Pirko <jiri@resnulli.us>
> Date: Sun, 12 Apr 2015 09:53:51 +0200
> 
> > Sat, Apr 11, 2015 at 06:12:25PM CEST, alexei.starovoitov@gmail.com wrote:
> >>On Fri, Apr 10, 2015 at 02:45:17PM +0200, Jiri Pirko wrote:
> >>> Okay. That was misunderstanding. I was thinking about using existing
> >>> flow_dissect. There are couple things which I'm scared of:
> >>> - there are eventually many fields to be added to dissection function and to
> >>>   the structure as well. Not sure how acceptable that would be for
> >>>   performance reasons when flow_dissect is used by different users...
> >>
> >>I share the same concern. I think flow_dissect is too performance
> >>critical to reuse by expanding 'struct flow_keys'.
> >>I think it would be better to generalize ovs's key_extract() into
> >>common piece of code that TC classifier and ovs datapath can use.
> >>It uses kernel internal 'struct sw_flow_key' which we can tweak to
> >>accommodate more users. It's already gigantic at 392 bytes, so
> >>split and a bit of diet would help too.
> > 
> > Yep, those are few next topics on my agenda.
> 
> This argument kinda ignores the fact that full flow dissection is run
> on _every_ single RX packet on basically all Intel chipsets.
> 
> Therefore, I cannot take seriously someone saying that it is too much
> overhead for a classifier.

I was taking about different thing. skb_flow_dissect() today is fast,
because it needs to copy very few fields into flow_keys, whereas
Jiri's classifier and ovs's key_extract copy pretty much everything
they see in the packet into gigantic sw_flow_key and that gigantic
struct is used a lookup key. Parsing itself is cheap, comparing to
copying everything.
