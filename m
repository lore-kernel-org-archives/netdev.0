From: Bastian Bittorf <bittorf@bluebottle.com>
Subject: Re: iproute2 / question: returncode when query a match
Date: Fri, 26 Jun 2015 09:31:45 +0200
Message-ID: <20150626073145.GU5927@medion.lan>
References: <20150604081638.GI16021@medion.lan>
 <20150614162616.GA25952@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bluebottle.com ([176.9.67.91]:36143 "EHLO
	mail.bluebottle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751773AbbFZHVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 03:21:47 -0400
Content-Disposition: inline
In-Reply-To: <20150614162616.GA25952@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Vadim Kochan <vadim4j@gmail.com> [15.06.2015 18:36]:
> > root@box:~ ip route list exact '0.0.0.0/8'
> > root@box:~ echo $?
> > 0
> > 
> > i expected an RC of != 0 when there is no match.
> > is this by design?
> > 
> > root@box:~ ip -V
> > ip utility, iproute2-ss4.0.0-1-openwrt
> 
> I think that RC != 0 only in case error happened, but may be its good
> idea to add such behaviour or add option to consider ret code
> if there is no results ?

ofcourse this is only useful for scripting:

# ip route list exact '0.0.0.0/8' || do_some_action

instead of the now used construct:
# [ -n "$( ip route list exact '0.0.0.0/8' )" ] || do_some_action

i'am sure there are other queries, where this also
makes sense. there are 2 possible ways for implementing this IMHO:

introduce a commandlineswitch like --pedantic
or just always throw an error 1 when there is no match like this:

root@box:~ echo foo | grep bar
root@box:~ echo $?
1

more opinions about that?

bye, bastian
