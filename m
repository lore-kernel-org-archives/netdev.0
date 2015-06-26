From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: iproute2 / question: returncode when query a match
Date: Fri, 26 Jun 2015 15:30:49 -0700
Message-ID: <20150626153049.74d86f33@urahara>
References: <20150604081638.GI16021@medion.lan>
	<20150614162616.GA25952@angus-think.lan>
	<20150626073145.GU5927@medion.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Vadim Kochan <vadim4j@gmail.com>
To: Bastian Bittorf <bittorf@bluebottle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34218 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434AbbFZWao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 18:30:44 -0400
Received: by pabvl15 with SMTP id vl15so75165009pab.1
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 15:30:43 -0700 (PDT)
In-Reply-To: <20150626073145.GU5927@medion.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Jun 2015 09:31:45 +0200
Bastian Bittorf <bittorf@bluebottle.com> wrote:

> * Vadim Kochan <vadim4j@gmail.com> [15.06.2015 18:36]:
> > > root@box:~ ip route list exact '0.0.0.0/8'
> > > root@box:~ echo $?
> > > 0
> > > 
> > > i expected an RC of != 0 when there is no match.
> > > is this by design?
> > > 
> > > root@box:~ ip -V
> > > ip utility, iproute2-ss4.0.0-1-openwrt
> > 
> > I think that RC != 0 only in case error happened, but may be its good
> > idea to add such behaviour or add option to consider ret code
> > if there is no results ?
> 
> ofcourse this is only useful for scripting:
> 
> # ip route list exact '0.0.0.0/8' || do_some_action
> 
> instead of the now used construct:
> # [ -n "$( ip route list exact '0.0.0.0/8' )" ] || do_some_action
> 
> i'am sure there are other queries, where this also
> makes sense. there are 2 possible ways for implementing this IMHO:
> 
> introduce a commandlineswitch like --pedantic
> or just always throw an error 1 when there is no match like this:
> 
> root@box:~ echo foo | grep bar
> root@box:~ echo $?
> 1
> 
> more opinions about that?
> 
> bye, bastian

Exit codes for ip route are already used to handle errors.
See current man page.

If you want to handle both errors and no match, the scripting tricks
to look for empty output are better.
