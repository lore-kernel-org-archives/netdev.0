From: Patrick McHardy <kaber@trash.net>
Subject: Re: HFSC dangerous behaviour (not a bug)
Date: Mon, 29 Oct 2007 11:55:31 +0100
Message-ID: <4725BC23.7000907@trash.net>
References: <20071028235224.M3269@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57248 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500AbXJ2K5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 06:57:48 -0400
In-Reply-To: <20071028235224.M3269@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys wrote:
> Hi All
> 
> During testing i found very strange thing. 
> After applying even example shaper:
> http://linux-ip.net/tc/hfsc.en/
> -------------
> [...]
> ---------------
> I had all traffic on eth0 stopped. Tried on br0 - same result. Even ARP 
> becoming non-functional.
> 
> After specifying correct default class everything worked fine.
> 
> In HTB if you dont specify default class, traffic just pass without 
> "shaping". 


HFSC drops unclassified packets. If you don't classify ARP properly,
things will break,

> Is it possible to keep same behaviour on both disciplines?
> Probably just dropping all traffic not good idea, cause if user working on 
> remote box by forgetting specifying default class or by mistake using 
> incorrect class number he will loose access to the box, if same interface is 
> used for tests on shaping and access.
> In same time it is good, and can show accurate results on shaping, without 
> bypassing some "forgotten" traffic.
> But at least it must be same, IMHO, on HTB and HFSC.


This came up a couple of times already. I don't like HTB's behaviour
since you don't notice when your classifiers are incomplete. So I'm
against changing HFSC to behave similar. HTB OTOH can't be changed
since users probably rely on that, not classifying ARP is a common
mistake.

