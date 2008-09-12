From: Grant Coady <grant_lkml@dodo.com.au>
Subject: Re: [stable] regression in iptables: recent filter
Date: Fri, 12 Sep 2008 13:29:43 +1000
Message-ID: <a4ojc4l86ro7kstsefumugi56s88v3fm91@4ax.com>
References: <ejijc4dc92n75s2el334e7dgdanngs7qv3@4ax.com> <20080912031132.GA6443@x200.localdomain>
Reply-To: Grant Coady <gcoady.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Grant Coady <gcoady.lk@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay03.mail-hub.dodo.com.au ([123.2.6.238]:39333 "EHLO
	relay03.mail-hub.dodo.com.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751852AbYILD3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 23:29:54 -0400
In-Reply-To: <20080912031132.GA6443@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Sep 2008 07:11:32 +0400, Alexey Dobriyan <adobriyan@gmail.com> wrote:

>On Fri, Sep 12, 2008 at 11:53:35AM +1000, Grant Coady wrote:
>> Last known good kernel: 2.6.24.7
>> 
>> # iptables -N calmrate
>> # iptables -A calmrate -p tcp -m state --state NEW \
>> 	-m recent --name listrate --update --rttl \
>> 	--seconds 60 --hitcount 60 -j DROP
>> iptables: Unknown error 4294967295
>> 
>> Fails for 2.6.25.17 and 2.6.26.5
>> 
>> dmesg + config: http://bugsplatter.id.au/kernel/boxen/deltree/
>
>You were einvaled by the following commit:
>
>Reloading module with ip_pkt_list_tot=60 should fix it.

Thanks, I just been through the sources and reached the same 
conclusion -- yes, okay with the ip_pkt_list_tot=60 :)

Not a very informative error message :(  The source needs some 
whitespace fixing too, but who cares?

Grant.
