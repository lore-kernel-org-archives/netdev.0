From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6.23+] ingress classify to [nf]mark
Date: Sun, 13 Jan 2008 14:44:44 -0500
Message-ID: <1200253484.4427.33.camel@localhost>
References: <47866C69.3080904@bspu.unibel.by>
	 <1200001167.4443.38.camel@localhost>  <4787A663.4030204@bspu.unibel.by>
	 <1200063541.4483.42.camel@localhost>  <4787D49E.6080906@bspu.unibel.by>
	 <1200107027.4477.36.camel@localhost>  <4788FF45.702@bspu.unibel.by>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mahatma@eu.by
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:8752 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164AbYAMTos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 14:44:48 -0500
Received: by py-out-1112.google.com with SMTP id u52so2636233pyb.10
        for <netdev@vger.kernel.org>; Sun, 13 Jan 2008 11:44:47 -0800 (PST)
In-Reply-To: <4788FF45.702@bspu.unibel.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


Please CC me in your responses (the way i do when i respond to you),
that way my filters prioritize your email. 

On Sat, 2008-12-01 at 15:56 -0200, Dzianis Kahanovich wrote:
> I in doubts only about "action continue".
> To "and/or" behaviour one of best usage are (example):

I dont think you should be touching the action part at all primarily
because actions can set the mark after classification. 
The action code (not the default) should be the override. IOW, if i
specify a ipt mark of some value i would expect that value to be what
goes into the network stack and not the default value you want. Same if
i had a series of actions which override each others settings of mark.

When we have a metadata action, we can remove the setting of tcindex
in the action OK result case (for now it doesnt harm).

In other words, just set the #ifndef action to set both the tcindex and
mark to some policy;

> # set bit 2 of mark to 0 (mark&0xfd|0) and continue
> tc filter add ... prio 1 ... flowid fd:0 action continue
> # continue
> tc filter add ... prio 2 ...
> 
> - in current ingress_enqueue() code IMHO "case TC_ACT_OK:" will not reached 
> for action continue. I use old (mark=...) solution only by this.
> 
> I think, "skb->mark = (skb->mark&(res.classid>>16))|TC_H_MIN(res.classid);" 
> must be in the end of ingress_enqueue() before "return result". And not 
> depended to "NET_CLS_ACT". But while not test it.
> Or this:
> ---
> #ifdef CONFIG_NET_SCH_INGRESS_TC2MARK
> #ifdef CONFIG_NET_CLS_ACT
> 	skb->mark = (skb->mark&(res.classid>>16))|TC_H_MIN(res.classid);
> #else
> 	skb->mark = res.classid;
> #endif
> #endif

Please refer to what i said above; if what i said still doesnt make
sense i can create (the simple) patch.

cheers,
jamal

