From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] tc class: Show class names from file
Date: Mon, 16 Mar 2015 15:22:30 +0200
Message-ID: <20150316132230.GA1100@angus-think.wlc.globallogic.com>
References: <1425400878-7608-1-git-send-email-vadim4j@gmail.com>
 <5505EFC4.1070403@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:33425 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752579AbbCPNeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 09:34:13 -0400
Received: by lbbzq9 with SMTP id zq9so30815851lbb.0
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 06:34:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5505EFC4.1070403@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 15, 2015 at 09:47:00PM +0100, Daniel Borkmann wrote:
> Hi Vadim,
> 
> On 03/03/2015 05:41 PM, Vadim Kochan wrote:
> >From: Vadim Kochan <vadim4j@gmail.com>
> >
> >It is possible to use class names from file /etc/iproute2/cls_names
> >which tc will use when showing class info:
> >
> >     # tc/tc -nm class show dev lo
> >	class htb 1:10 parent 1:1 leaf 10: prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
> >	class htb 1:1 root rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
> >	class htb web#1:20 parent 1:1 leaf 20: prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
> >	class htb 1:2 root rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
> >	class htb 1:30 parent 1:1 leaf 30: prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> >	class htb voip#1:40 parent 1:2 leaf 40: prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
> >	class htb 1:50 parent 1:2 leaf 50: prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
> >	class htb 1:60 parent 1:2 leaf 60: prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> >
> >or to specify via file path:
> >
> >     # tc/tc -nm -cf /tmp/cls_names class show dev lo
> >
> >Class names file contains simple "maj:min  name" structure:
> >
> >1:20    web
> >1:40    voip
> >
> >Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> 
> in your patch, there are a couple of malloc() calls in your db
> creation, that you should check if they actually fail, see i.e.
> db_names_alloc(). Would be good if you could follow-up with a fix.
> 
> Thanks,
> Daniel

Hi,

Sure I will do.

Also I was thinking about to get rid of this '-nm | -name' option and
resolve class names by default if they are in /etc/iproute2/cls_names or
specified by -cf option, what do you think ?

Regards,
