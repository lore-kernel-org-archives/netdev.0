From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHv2 net 2/3] openvswitch: Treat IP_CT_RELATED as new
Date: Mon, 19 Oct 2015 11:03:32 +0200
Message-ID: <20151019090332.GA7104@pox.localdomain>
References: <1445018901-18839-1-git-send-email-joestringer@nicira.com>
 <1445018901-18839-3-git-send-email-joestringer@nicira.com>
 <20151017075233.GC13981@pox.localdomain>
 <CANr6G5xmO6D0Yu0VXeaJLbO1aK2tQ5_vHUNRkawK1zNFMJz=aw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:33725 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752869AbbJSJDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 05:03:45 -0400
Received: by lbbpp2 with SMTP id pp2so108734246lbb.0
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 02:03:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CANr6G5xmO6D0Yu0VXeaJLbO1aK2tQ5_vHUNRkawK1zNFMJz=aw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/19/15 at 12:07am, Joe Stringer wrote:
> > I'm probably missing something obvious. Why is the reply direction
> > not considered NEW? Wouldn't this consider an ICMPv6 as related+new
> > depending on simply the direction?
> 
> My thoughts were along the lines "If something is a reply, that
> implies that state is held, and therefore it cannot be NEW (where NEW
> means no state is available)". However, if you consider that the
> 'related' connection is an independent connection with its own state,
> but the 'reply' bit refers to the original connection, my original
> premise breaks. Furthermore, looking at how it's used in netfilter
> core and the ICMP proto handler, it looks like both of these cases
> should be considered NEW. I can respin.
> 
> Do you have a specific case in mind here? It would be useful for
> extending the OVS testsuite.

It's tricky. A typical use case would be an active FTP connection
where the data connection is established in the reply direction
and marked related if I'm not mistaken.

OTOH, an ICMP sent in response should not be considered NEW. It
really depends on our definition of NEW towards the user.
