From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [IPROUTE2] Compatibility with iptables 1.4.0
Date: Mon, 24 Dec 2007 11:57:37 -0500
Message-ID: <1198515457.4427.16.camel@localhost>
References: <20071224160739.M84357@visp.net.lb>
	 <1198513837.4427.8.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:35906 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbXLXQ5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 11:57:42 -0500
Received: by wa-out-1112.google.com with SMTP id v27so2789934wah.23
        for <netdev@vger.kernel.org>; Mon, 24 Dec 2007 08:57:40 -0800 (PST)
In-Reply-To: <1198513837.4427.8.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I just submitted a tested, slightly reduced patch (example we dont need
to register matches) and it works as expected now. Thanks for the
excellent work Denys.

Pablo, below looks an oversight.
I think there are some libraries like the mark target need also to be
backward compatible.

cheers,
jamal

On Mon, 2007-24-12 at 11:30 -0500, jamal wrote:

> Grr. I tested with a different iptables target and thought the rest work
> in the same manner. iptables needs to be consistent.
> 
> -----
> lilsol:~# export IPTABLES_LIB_DIR=/root/iptables-1.4.0/extensions/
> lilsol:~# tc actions add action ipt -j TOS --set-tos
> Maximize-Reliability
> tablename: mangle hook: NF_IP_POST_ROUTING
>         target: TOS set Maximize-Reliability  index 0
> lilsol:~# tc actions ls action ipt
> 
>         action order 0: tablename: mangle  hook: NF_IP_POST_ROUTING
>         target TOS set Maximize-Reliability
>         index 2 ref 1 bind 0
> // the above is what i tested
> // below is what you did
> lilsol:~# tc actions add action ipt -j mark --set-mark 3
> /root/iptables-1.4.0/extensions/: cannot read file data: Is a directory
>  failed to find target mark
> 
> bad action parsing
> parse_action: bad value (5:ipt)!
> Illegal "action"
> Command "add" is unknown, try "tc actions help".
> lilsol:~#
> ------------
> 
> Applying your patch ....
> Seems corrupt; let me fix it up, test it and resend it to Stephen.
> 
> cheers,
> jamal
> 

